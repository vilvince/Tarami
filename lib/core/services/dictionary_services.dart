import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarami_application/features/dictionary/model/dictionary_model.dart';

class DictionaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  /// Get all words from dictionary collection
  Future<List<DictionaryEntry>> getAllWords() async {
    try {
      print('Fetching words from Firebase...');

      // Query the 'dictionary' collection and order results by 'word'
      final query = await _firestore
          .collection('dictionary')
          .orderBy('word')
          .get();

      // Convert each document into a DictionaryEntry object
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

  /// Search words by prefix (case-insensitive)
  Future<List<DictionaryEntry>> searchWords(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      // If search is empty, return all words
      return await getAllWords();
    }

    try {
      print('Searching for: $searchTerm');

      // Fetch all words from Firestore once
      final allWords = await getAllWords();
      final lower = searchTerm.toLowerCase();

      // Filter in Dart (checks if word starts with search term)
      final results = allWords.where((entry) {
        return entry.word.toLowerCase().startsWith(lower);
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

      // Fetch the document from Firestore by its ID
      final doc = await _firestore
          .collection('dictionary')
          .doc(documentId)
          .get();

      // If document exists, convert it into a DictionaryEntry
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
