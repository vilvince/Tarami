import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/submissions/data/submission_model.dart';

class AdminSubmissionsService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Gets a real-time stream of all reviewed submissions (approved, denied, flagged)
  Stream<List<SubmissionModel>> getReviewedSubmissionStream(){
    return _firestore
        .collection('word_submissions')
        .where('status', whereIn: ['approved', 'denied', 'flagged'])
        .orderBy('reviewed_at', descending: true) // Show most recent first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SubmissionModel.fromFirestore(doc)).toList();
    });
  }
}