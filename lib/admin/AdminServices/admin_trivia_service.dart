import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/trivia/data/trivia_model.dart';

class TriviaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'trivia';

  /// READ: Get a real-time stream of all trivia items
  /// Returns items ordered by creation date (newest first)
  Stream<List<Trivia>> getTriviaStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Trivia.fromFirestore(doc))
          .toList();
    });
  }

  /// CREATE: Add a new trivia document
  Future<void> addTrivia(String text) async {
    if (text.trim().isEmpty) {
      throw Exception('Trivia text cannot be empty');
    }

    try {
      await _firestore.collection(_collectionName).add({
        'text': text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add trivia: $e');
    }
  }

  /// UPDATE: Update an existing trivia document
  Future<void> updateTrivia(String id, String newText) async {
    if (newText.trim().isEmpty) {
      throw Exception('Trivia text cannot be empty');
    }

    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'text': newText.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update trivia: $e');
    }
  }

  /// DELETE: Delete a trivia document by its ID
  Future<void> deleteTrivia(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete trivia: $e');
    }
  }

  /// GET: Fetch a single trivia by ID (optional utility method)
  Future<Trivia?> getTriviaById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return Trivia.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch trivia: $e');
    }
  }

  /// BULK DELETE: Delete all trivia (use with caution!)
  Future<void> deleteAllTrivia() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(_collectionName).get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all trivia: $e');
    }
  }
}