import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarami_application/data/models/trivia_model.dart';

class TriviaService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TriviaModel>> getTrivia(){
    return _firestore
        .collection('trivia')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TriviaModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }
}
