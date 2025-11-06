import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current admin user ID
  String? get _adminUserId => _auth.currentUser?.uid;

  // ==========================================
  // GET SUBMISSIONS
  // ==========================================

  /// Get pending submissions stream
  Stream<List<Map<String, dynamic>>> getPendingSubmissions() {
    return _firestore
        .collection('word_submissions')
        .where('status', isEqualTo: 'pending')
        .orderBy('date_submitted', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    });
  }

  /// Get reviewed submissions stream (approved, denied, flagged)
  Stream<List<Map<String, dynamic>>> getReviewedSubmissions() {
    return _firestore
        .collection('word_submissions')
        .where('status', whereIn: ['approved', 'denied', 'flagged'])
        .orderBy('reviewed_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get all submissions stream
  Stream<List<Map<String, dynamic>>> getAllSubmissions() {
    return _firestore
        .collection('word_submissions')
        .orderBy('date_submitted', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ==========================================
  // APPROVE SUBMISSION
  // ==========================================

  /// Approve submission and add to dictionary
  /// Approve submission and add to dictionary
  Future<Map<String, dynamic>> approveSubmission(String submissionId) async {
    try {
      if (_adminUserId == null) {
        return {'success': false, 'message': 'Admin not authenticated'};
      }

      final submissionDoc = await _firestore.collection('word_submissions').doc(submissionId).get();
      if (!submissionDoc.exists) {
        return {'success': false, 'message': 'Submission not found'};
      }

      final submissionData = submissionDoc.data()!;

      // ✅ FIX #1: Parse the combined example_sentence field right away.
      final combinedExample = submissionData['example_sentence'] as String? ?? '|';
      final exampleParts = combinedExample.split('|');
      final dialectExample = exampleParts.isNotEmpty ? exampleParts[0] : '';
      final englishExample = exampleParts.length > 1 ? exampleParts[1] : '';

      final word = (submissionData['word'] as String).trim();
      final dialectSubmitted = (submissionData['dialect'] as String).trim();
      final dialectKey = _dialectNameToKey(dialectSubmitted);

      final existingWordQuery = await _firestore.collection('dictionary').where('word', isEqualTo: word).limit(1).get();

      if (existingWordQuery.docs.isNotEmpty) {
        // Word exists - check if dialect already exists
        final wordDoc = existingWordQuery.docs.first;
        final wordData = wordDoc.data();
        final translations = List<Map<String, dynamic>>.from(wordData['translations'] ?? []);

        final dialectExists = translations.any((t) => t['dialect'] == dialectKey);

        if (dialectExists) {
          // This part is for TRUE duplicates (same word, same dialect) and is correct.
          await _updateSubmissionStatus(submissionId, 'denied', reviewNotes: 'Duplicate: Word and dialect already exist in dictionary');
          return {'success': false, 'message': 'Duplicate detected. Word with this dialect already exists.', 'isDuplicate': true};
        }

        // Add new dialect translation to existing word
        translations.add({
          'dialect': dialectKey,
          'translation': submissionData['translation'] ?? '',
          'phonetics': submissionData['phonetics'] ?? '',
          // ✅ FIX #2: Use the correctly parsed dialectExample variable.
          'sample_sentence': dialectExample,
        });

        // Update word document
        await wordDoc.reference.update({
          'translations': translations,
          'updated_at': FieldValue.serverTimestamp(),
        });

      } else {
        // Word doesn't exist - create new dictionary entry
        await _firestore.collection('dictionary').add({
          'word': word,
          'definition': submissionData['definition'] ?? '',
          'part_of_speech': submissionData['part_of_speech'] ?? '',
          'tagalog': submissionData['tagalog_translation'] ?? '', // ✅ FIX #3: Match the correct field name
          'example_sentence': englishExample, // ✅ FIX #4: Use the parsed English example
          'synonyms': _parseSynonyms(submissionData['synonyms']),
          'translations': [{
            'dialect': dialectKey,
            'translation': submissionData['translation'] ?? '',
            'phonetics': submissionData['phonetics'] ?? '',
            'sample_sentence': dialectExample, // ✅ FIX #5: Use the parsed dialect example
          }],
          'created_at': FieldValue.serverTimestamp(),
          'created_by': 'admin',
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // Update submission status to approved
      await _updateSubmissionStatus(submissionId, 'approved', reviewNotes: 'Approved and added to dictionary');
      return {'success': true, 'message': 'Submission approved and added to dictionary'};

    } catch (e) {
      print('Error approving submission: $e');
      // Also deny the submission if an unexpected error occurs
      await _updateSubmissionStatus(submissionId, 'denied', reviewNotes: 'Failed to process: $e');
      return {'success': false, 'message': 'Failed to approve submission: $e'};
    }
  }

  // ==========================================
  // DENY SUBMISSION
  // ==========================================

  Future<Map<String, dynamic>> denySubmission(
      String submissionId, {
        String? reason,
      }) async {
    try {
      if (_adminUserId == null) {
        return {
          'success': false,
          'message': 'Admin not authenticated',
        };
      }

      await _updateSubmissionStatus(
        submissionId,
        'denied',
        reviewNotes: reason,
        rejectionReason: reason,
      );

      return {
        'success': true,
        'message': 'Submission denied',
      };

    } catch (e) {
      print('Error denying submission: $e');
      return {
        'success': false,
        'message': 'Failed to deny submission: $e',
      };
    }
  }

  // ==========================================
  // FLAG SUBMISSION
  // ==========================================

  Future<Map<String, dynamic>> flagSubmission(
      String submissionId, {
        String? reason,
      }) async {
    try {
      if (_adminUserId == null) {
        return {
          'success': false,
          'message': 'Admin not authenticated',
        };
      }

      // 1️⃣ Get the submission document
      final submissionDoc = await _firestore
          .collection('word_submissions')
          .doc(submissionId)
          .get();

      if (!submissionDoc.exists) {
        return {
          'success': false,
          'message': 'Submission not found',
        };
      }

      final submissionData = submissionDoc.data()!;
      final userId = submissionData['submitted_by'] ??
          submissionData['submittedId'] ??
          submissionData['userId'] ??
          submissionData['submitted_id'];

      final userEmail = submissionData['submitted_by_email'] ??
          submissionData['user_email'] ??
          submissionData['submittedEmail'];

      if (userId == null || userId.toString().isEmpty) {
        return {
          'success': false,
          'message': 'No valid user ID found in submission document',
        };
      }

      // 2️⃣ Update the submission status to "flagged"
      await _updateSubmissionStatus(
        submissionId,
        'flagged',
        reviewNotes: reason ?? 'Flagged for review',
      );

      // 3️⃣ Update the user's flag count
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        return {
          'success': false,
          'message': 'User document not found',
        };
      }

      final userData = userDoc.data()!;
      final currentFlagCount = userData['flagCount'] ?? 0;
      final newFlagCount = currentFlagCount + 1;

      // 4️⃣ Create flag record
      final flagRecord = {
        'reason': reason ?? 'Flagged for review',
        'date': Timestamp.now(),
        'submissionId': submissionId,
        'flaggedBy': _adminUserId,
      };

      // 5️⃣ Update user document
      await userRef.update({
        'flagCount': newFlagCount,
        'flags': FieldValue.arrayUnion([flagRecord]),
      });
      //Restirction logic

      if (newFlagCount >= 3 && newFlagCount <= 4){
        final LiftDate = DateTime.now().add(const Duration(days: 7));

        await userRef.update({
          'isTemporarilyRestricted': true,
          'restrictionLiftDate': LiftDate,
        });

        print("User temporarily restricted for 7 days (until $LiftDate)");

      } else if (newFlagCount >= 5) {
        await userRef.update({
          'isPermanentlyBanned': true,
        });

        print("⛔ User permanently banned due to repeated offenses.");
      }

      return {
        'success': true,
        'message': 'Submission flagged. User now has $newFlagCount flag(s).',
        'flagCount': newFlagCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to flag submission: $e',
      };
    }
  }


  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Update submission status
  Future<void> _updateSubmissionStatus(
      String submissionId,
      String status, {
        String? reviewNotes,
        String? rejectionReason,
      }) async {
    final updateData = {
      'status': status,
      'reviewed_at': FieldValue.serverTimestamp(),
      'reviewed_by': _adminUserId,
    };

    if (reviewNotes != null) {
      updateData['review_notes'] = reviewNotes;
    }

    if (rejectionReason != null) {
      updateData['rejection_reason'] = rejectionReason;
    }

    await _firestore
        .collection('word_submissions')
        .doc(submissionId)
        .update(updateData);
  }

  /// Convert dialect display name to database key
  String _dialectNameToKey(String dialectName) {
    final normalized = dialectName.toLowerCase().trim();

    switch (normalized) {
      case 'central bikol':
        return 'central_bikol';
      case 'west miraya':
        return 'west_miraya';
      case 'east miraya':
        return 'east_miraya';
      case 'libon bikol':
        return 'libon_bikol';
      default:
      // If already in key format, return as is
        return normalized.replaceAll(' ', '_');
    }
  }

  /// Parse synonyms from comma-separated string to array
  List<String> _parseSynonyms(dynamic synonyms) {
    if (synonyms == null) return [];

    if (synonyms is List) {
      return synonyms.map((s) => s.toString().trim()).toList();
    }

    if (synonyms is String) {
      return synonyms
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [];
  }

  // ==========================================
  // GET SUBMISSION DETAILS
  // ==========================================

  Future<Map<String, dynamic>?> getSubmissionDetails(String submissionId) async {
    try {
      final doc = await _firestore
          .collection('word_submissions')
          .doc(submissionId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;

    } catch (e) {
      print('Error getting submission details: $e');
      return null;
    }
  }
}