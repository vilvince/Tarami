import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarami_application/features/dictionary/model/dictionary_model.dart';

class DictionaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all words from dictionary collection
  Future<List<DictionaryEntry>> getAllWords() async {
    try {
      print('Fetching words from Firebase...');

      final query = await _firestore
          .collection('dictionary')
          .orderBy('word')
          .get();

      final results = query.docs.map((doc) {
        print('Processing word: ${doc.data()['word']}');
        return DictionaryEntry.fromFirestore(doc.data(), doc.id);
      }).toList();

      print('Successfully loaded ${results.length} words');
      return results;

    } catch (e) {
      print('Error loading words: $e');
      throw Exception('Failed to load dictionary: $e');
    }
  }

  /// Search words by English term
  Future<List<DictionaryEntry>> searchWords(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return await getAllWords();
    }

    try {
      print('Searching for: $searchTerm');

      // Search for words that start with the search term
      final query = await _firestore
          .collection('dictionary')
          .where('word', isGreaterThanOrEqualTo: searchTerm.toLowerCase())
          .where('word', isLessThanOrEqualTo: searchTerm.toLowerCase() + '\uf8ff')
          .orderBy('word')
          .get();

      final results = query.docs.map((doc) {
        return DictionaryEntry.fromFirestore(doc.data(), doc.id);
      }).toList();

      print('Found ${results.length} results for "$searchTerm"');
      return results;

    } catch (e) {
      print('Error searching words: $e');
      throw Exception('Failed to search words: $e');
    }
  }

  /// Get specific word by document ID
  Future<DictionaryEntry?> getWordById(String documentId) async {
    try {
      print('Getting word by ID: $documentId');

      final doc = await _firestore
          .collection('dictionary')
          .doc(documentId)
          .get();

      if (doc.exists && doc.data() != null) {
        print('Found word: ${doc.data()!['word']}');
        return DictionaryEntry.fromFirestore(doc.data()!, doc.id);
      }

      print('Word not found');
      return null;

    } catch (e) {
      print('Error getting word by ID: $e');
      throw Exception('Failed to get word: $e');
    }
  }
}