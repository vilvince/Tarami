import 'package:cloud_firestore/cloud_firestore.dart';

class WordModel {
  final String id;
  final String word;
  final String dialect;
  final String dialectKey;

  final String? translation;
  final String? phonetic;
  final String? tagalog;
  final String? partOfSpeech;
  final String? definition;
  final String? exampleDialect;
  final String? exampleEnglish;
  final String? synonyms;

  WordModel({
    required this.id,
    required this.word,
    required this.dialect,
    required this.dialectKey,
    this.translation,
    this.phonetic,
    this.tagalog,
    this.partOfSpeech,
    this.definition,
    this.exampleDialect,
    this.exampleEnglish,
    this.synonyms,
  });

  String get uniqueId => '$id-$dialectKey';

  factory WordModel.fromFirestore(DocumentSnapshot doc, Map<String, dynamic> translationData){
    final docData = doc.data() as Map<String, dynamic>? ?? {};
    final String dialectKey = translationData['dialect'] ?? ''; // Keep original key

    // Helper to convert dialect keys like "west_miraya" to "West Miraya"
    String formatDialect(String key) {
      return key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }

    final String dialectExample = translationData['sample_sentence'] ?? '';
    final String englishExample = docData['example_sentence'] ?? '';

    // Safely handle the 'synonyms' field, which could be a List or a String
    String synonymsString = 'N/A';
    final dynamic synonymsValue = docData['synonyms'];
    if (synonymsValue is List && synonymsValue.isNotEmpty) {
      synonymsString = synonymsValue.join(', ');
    } else if (synonymsValue is String && synonymsValue.isNotEmpty) {
      synonymsString = synonymsValue;
    }

    return WordModel(
      id: doc.id,
      word: docData['word'] ?? '',
      dialect: formatDialect(dialectKey), // Display formatted version
      dialectKey: dialectKey, // ✅ Store original snake_case key for deletion
      translation: translationData['translation'] ?? '',
      phonetic: translationData['phonetics'] ?? '',
      tagalog: docData['tagalog'] ?? '',
      partOfSpeech: docData['part_of_speech'] ?? '',
      definition: docData['definition'] ?? '',
      exampleDialect: dialectExample,
      exampleEnglish: englishExample,
      synonyms: synonymsString,
    );
  }
}