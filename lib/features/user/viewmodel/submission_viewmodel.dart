import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/data/models/submission_model.dart';

class SubmissionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Submission> _submissions = [];
  bool _isLoading = true;
  String? _error;

  // Getters
  List<Submission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SubmissionViewModel() {
    _loadSubmissions();
  }

  // Load user submissions directly from "word_submissions" collection
  Future<void> _loadSubmissions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }


      // Query the word_submissions collection directly (no orderBy to avoid index requirement)
      final querySnapshot = await _firestore
          .collection('word_submissions')
          .where('submitted_by_email', isEqualTo: user.email)
          .get();


      // Convert Firestore documents to Submission objects
      _submissions = querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Parse example sentences (stored as combined string)
        final exampleSentence = data['example_sentence'] as String? ?? '';
        final examples = exampleSentence.split('|');
        final dialectExample = examples.isNotEmpty ? examples[0].trim() : '';
        final englishExample = examples.length > 1 ? examples[1].trim() : '';


        return Submission(
          id: data['submitted_id'] ?? doc.id,
          word: data['word'] ?? '',
          dialect: data['dialect'] ?? '',
          date: data['date_submitted'] != null
              ? (data['date_submitted'] as Timestamp).toDate()
              : DateTime.now(),
          status: _capitalizeStatus(data['status'] ?? 'pending'),
          translation: data['translation'] ?? '',
          phonetics: data['phonetics'] ?? '',
          partOfSpeech: data['part_of_speech'] ?? '',
          tagalog: data['tagalog_translation'] ?? '',
          definition: data['definition'] ?? '',
          exampleInDialect: dialectExample,
          exampleInEnglish: englishExample,
          synonyms: data['synonyms'] ?? 'N/A',
          rejectionReason: data['rejection_reason'] ?? data['review_notes'],

        );
      }).toList();

      print('Successfully loaded ${_submissions.length} submissions');

      // Sort by date in the app (newest first) to avoid needing Firestore composite index
      _submissions.sort((a, b) => b.date.compareTo(a.date));

    } catch (e) {
      _error = 'Failed to load submissions: $e';
      print('Error loading submissions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to capitalize status
  String _capitalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'denied':
        return 'Denied';
      case 'flagged':
        return 'Flagged';
      default:
        return 'Pending';
    }
  }

  // Get submissions by status
  List<Submission> getSubmissionsByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _submissions;
    }
    return _submissions.where((submission) =>
    submission.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Refresh submissions
  Future<void> refreshSubmissions() async {
    await _loadSubmissions();
  }

  // Find submission by ID
  Submission? getSubmissionById(String id) {
    try {
      return _submissions.firstWhere((submission) => submission.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get count by status
  int getCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _submissions.length;
    }
    return _submissions.where((submission) =>
    submission.status.toLowerCase() == status.toLowerCase()).length;
  }
}