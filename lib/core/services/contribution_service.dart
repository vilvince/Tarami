import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/data/models/contribute_model.dart';

class ContributionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collectionName = 'word_submissions';
  static const int _maxSubmissionsPerDay = 5;

  // Submit a new word contribution
  Future<bool> submitContribution(ContributeModel contribution) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check daily submission limit first
      final canSubmit = await checkDailySubmissionLimit();
      if (!canSubmit) {
        throw Exception('Daily submission limit reached');
      }

      // Generate document ID
      final docRef = _firestore.collection(_collectionName).doc();

      // Prepare submission data
      final submissionData = {
        'submitted_id': docRef.id,
        'submitted_by_email': user.email ?? 'anonymous',
        'date_submitted': FieldValue.serverTimestamp(),
        'word': contribution.word,
        'dialect': contribution.dialect,
        'translation': contribution.translation,
        'phonetics': contribution.phonetic,
        'tagalog_translation': contribution.tagalogTranslation,
        'part_of_speech': contribution.partOfSpeech,
        'definition': contribution.definition,
        'example_sentence': '${contribution.exampleSentenceInDialect}|${contribution.exampleSentenceInEnglish}', // Storing both examples
        'synonyms': contribution.synonyms ?? '',
        'status': 'pending', // Default status
      };

      // Submit to Firestore
      await docRef.set(submissionData);
      return true;

    } catch (e) {
      print('Error submitting contribution: $e');
      return false;
    }
  }

  // Check if user can submit more words today
  Future<bool> checkDailySubmissionLimit() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return false;
      }

      // Use the simplified method that doesn't require indexes
      final count = await getTodaySubmissionCountSimple();
      print('Current submission count: $count, Max allowed: $_maxSubmissionsPerDay');
      return count < _maxSubmissionsPerDay;

    } catch (e) {
      print('Error checking submission limit: $e');
      return false;
    }
  }

  // Simplified method to count today's submissions (no indexes needed)
  Future<int> getTodaySubmissionCountSimple() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      // Get all user submissions (single where clause, no index needed)
      final allSubmissions = await _firestore
          .collection(_collectionName)
          .where('submitted_by_email', isEqualTo: user.email)
          .get();

      if (allSubmissions.docs.isEmpty) {
        print('No submissions found for user');
        return 0;
      }

      // Filter for today's submissions manually
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      int todayCount = 0;

      for (final doc in allSubmissions.docs) {
        final data = doc.data();
        final timestamp = data['date_submitted'] as Timestamp?;

        if (timestamp != null) {
          final submissionDate = timestamp.toDate();
          if (submissionDate.isAfter(today) && submissionDate.isBefore(tomorrow)) {
            todayCount++;
          }
        }
      }

      return todayCount;

    } catch (e) {
      print('Error in getTodaySubmissionCountSimple: $e');
      return 0;
    }
  }

  // Get current submission count for today (using simplified method)
  Future<int> getTodaySubmissionCount() async {
    // Use the simplified method that doesn't require indexes
    return getTodaySubmissionCountSimple();
  }




  // Get user's submissions by status
  Future<List<Map<String, dynamic>>> getUserSubmissions({String? status}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      Query query = _firestore
          .collection(_collectionName)
          .where('submitted_by_email', isEqualTo: user.email)
          .orderBy('date_submitted', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();

    } catch (e) {
      print('Error getting user submissions: $e');
      return [];
    }
  }

  // Stream for real-time updates of user submissions
  Stream<List<Map<String, dynamic>>> getUserSubmissionsStream({String? status}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    Query query = _firestore
        .collection(_collectionName)
        .where('submitted_by_email', isEqualTo: user.email)
        .orderBy('date_submitted', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        }).toList()
    );
  }
}
