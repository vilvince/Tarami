

import 'package:cloud_firestore/cloud_firestore.dart';

class DictionaryEntry {
  final String id;
  final String word;
  final String definition;
  final String partOfSpeech;
  final String? phonetics;
  String? getPhoneticsForDialect(String dialect) {
    try {
      return translations
          .firstWhere((t) => t.dialect.toLowerCase() == dialect.toLowerCase())
          .phonetics;
    } catch (e) {
      return null;
    }
  }

  final String? tagalog;
  final String? exampleSentence;
  final List<String> synonyms;
  final List<Translation> translations;
  final String category;
  final bool hasTextToSpeech;
  final bool isActive;

  DictionaryEntry({
    required this.id,
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    this.phonetics,
    this.tagalog,
    this.exampleSentence,
    this.synonyms = const [],
    this.translations = const [],
    this.category = 'general',
    this.hasTextToSpeech = false,
    this.isActive = true,
  });

  factory DictionaryEntry.fromFirestore(Map<String, dynamic> data, String id) {
    return DictionaryEntry(
      id: id,
      word: data['word'] ?? '',
      definition: data['definition'] ?? '',
      partOfSpeech: data['part_of_speech'] ?? '',
      phonetics: data['phonetics'],
      tagalog: data['tagalog'],
      exampleSentence: data['example_sentence'],
      synonyms: _parseSynonyms(data['synonyms']),
      translations: (data['translations'] as List<dynamic>?)
          ?.map((t) => Translation.fromMap(t as Map<String, dynamic>))
          .toList() ?? [],
      category: data['category'] ?? 'general',
      hasTextToSpeech: data['has_text_to_speech'] ?? false,
      isActive: data['is_active'] ?? true,
    );
  }

  // Add this helper method to handle both String and List formats
  static List<String> _parseSynonyms(dynamic synonymsData) {
    if (synonymsData == null) {
      return [];
    }

    // If it's already a List
    if (synonymsData is List) {
      return List<String>.from(synonymsData);
    }

    // If it's a String (comma-separated)
    if (synonymsData is String) {
      if (synonymsData.trim().isEmpty) {
        return [];
      }
      return synonymsData
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [];
  }

  // Get translation for specific dialect
  String? getTranslationForDialect(String dialect) {
    try {
      return translations
          .firstWhere((t) => t.dialect.toLowerCase() == dialect.toLowerCase())
          .translation;
    } catch (e) {
      return null;
    }
  }

  // Get sample sentence for specific dialect
  String? getSampleSentenceForDialect(String dialect) {
    try {
      return translations
          .firstWhere((t) => t.dialect.toLowerCase() == dialect.toLowerCase())
          .sampleSentence;
    } catch (e) {
      return null;
    }
  }
}

class Translation {
  final String dialect;
  final String? translation;
  final String? sampleSentence;
  final String? phonetics;

  Translation({
    required this.dialect,
    this.translation,
    this.sampleSentence,
    this.phonetics,
  });

  factory Translation.fromMap(Map<String, dynamic> data) {
    return Translation(
      dialect: data['dialect'] ?? '',
      translation: data['translation'],
      sampleSentence: data['sample_sentence'],
      phonetics: data['phonetics'],
    );
  }
}