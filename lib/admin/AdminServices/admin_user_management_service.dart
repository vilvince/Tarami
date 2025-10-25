import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tarami_application/admin/features/user_management/data/user_model.dart'; // Adjust path to your user_model.dart file

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches ALL users and combines them with their submission counts.
  Future<List<UserModel>> fetchAllUsersWithSubmissionCount() async {
    // We use .get() instead of .snapshots() for a one-time fetch.
    final usersSnapshot = await _firestore.collection('users').get();
    final submissionsSnapshot = await _firestore.collection('word_submissions').get();

    // 1. Create a map to efficiently count submissions by email.
    final submissionCounts = <String, int>{};
    for (final doc in submissionsSnapshot.docs) {
      final data = doc.data();
      final email = (data['submitted_by_email'] ?? '').toString();
      if (email.isNotEmpty) {
        submissionCounts[email] = (submissionCounts[email] ?? 0) + 1;
      }
    }

    // 2. Map the user documents and attach the submission count.
    return usersSnapshot.docs.map((doc) {
      final user = UserModel.fromFirestore(doc);
      final count = submissionCounts[user.email] ?? 0;
      return user.copyWith(submittedWords: count);
    }).toList();
  }

  /// Deletes a user's document.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
