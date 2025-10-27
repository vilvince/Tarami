import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/word_management/data/word_model.dart'; // Adjust this path if needed

class WordManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = "dictionary";

  /// Fetches all documents from the 'dictionary' and flattens them into a list
  /// of WordModels, one for each dialect translation.
  Future<List<WordModel>> getAllDictionaryWords() async {
    try {
      final snapshot = await _firestore.collection('dictionary').get();
      final List<WordModel> flattenedWords = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['translations'] is List) {
          final translations = List<Map<String, dynamic>>.from(data['translations']);
          for (final translationMap in translations) {
            // FIX: Corrected typo from fromFireStore to fromFirestore
            flattenedWords.add(WordModel.fromFirestore(doc, translationMap));
          }
        }
      }
      return flattenedWords;
    } catch (e) {
      print("Error fetching dictionary words: $e");
      throw Exception("Failed to load dictionary words.");
    }
  }

  /// Removes specific dialect translations from dictionary documents.
  /// If a document's translations array becomes empty, the document is deleted.
  Future<void> deleteSelected(Map<String, List<String>> deletions) async {
    if (deletions.isEmpty) return;

    final writeBatch = _firestore.batch();
    final collection = _firestore.collection(_collectionName);

    // Use a standard `for...in` loop which correctly handles `await`.
    for (final docId in deletions.keys) {
      final dialectsToDelete = deletions[docId]!;
      final docRef = collection.doc(docId);

      // We must read the document first to get its current translations.
      final snapshot = await docRef.get();
      if (!snapshot.exists) continue;

      final data = snapshot.data() as Map<String, dynamic>;
      final translations = List<Map<String, dynamic>>.from(data['translations'] ?? []);

      // Remove the translations marked for deletion.
      translations.removeWhere((entry) => dialectsToDelete.contains(entry['dialect']));

      if (translations.isEmpty) {
        // If no translations are left, delete the entire document.
        writeBatch.delete(docRef);
      } else {
        // Otherwise, update the document with the remaining translations.
        writeBatch.update(docRef, {'translations': translations});
      }
    }

    // This will now be called only after the loop has finished adding all operations.
    await writeBatch.commit();
  }
}