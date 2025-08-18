import 'package:flutter/foundation.dart';

class DictionaryViewModel extends ChangeNotifier {
  final List<String> _dialects = [
    'Central Bikol',
    'West Miraya',
    'East Miraya',
    'Libon Bikol'
  ];
  int _selectedDialectIndex = 0;
  String? _selectedWord;

  final Map<String, List<String>> _words = {
    'Central Bikol': [
      'Aback', 'Banana', 'Cat', 'Dog', 'Elephant',
      'Fish', 'Giraffe', 'House', 'Ice', 'Juice',
      'Kite', 'Lion', 'Monkey', 'Nest', 'Orange',
      'Pencil', 'Queen', 'Rabbit', 'Sun', 'Tiger',
      'Umbrella', 'Violin', 'Water', 'Xylophone', 'Yogurt', 'Zebra'
    ],
    'West Miraya': ['Agom', 'Balay', 'Dakul', 'Gadan', 'Huron'],
    'East Miraya': ['Abaw', 'Basura', 'Gikan', 'Irog', 'Kalayo'],
    'Libon Bikol': ['Agingay', 'Bayani', 'Daraga', 'Ilaw', 'Kabalo'],
  };

  final Map<String, Map<String, String>> _translations = {
    'Aback': {
      'Central Bikol': 'Nakigkig',
      'West Miraya': 'Nagbulag',
      'East Miraya': 'Nagulat',
      'Libon Bikol': 'Nasorpresa',
    },
  };

  final Map<String, Map<String, String>> _sampleSentences = {
    'Aback': {
      'Central Bikol': 'Nag-abot si Juan na nakigkig sa sorpresa.',
      'West Miraya': 'Si Pedro nagbagas sa huring balita.',
      'East Miraya': 'Nagbulag si Maria sa pag-abot ninda.',
      'Libon Bikol': 'Nagsopresa siya sa regalo.',
    },
  };

  final Map<String, List<String>> _synonyms = {
    'Aback': ['Surprised', 'Startled'],
    'Surprised': ['Aback', 'Astonished'],
    'Startled': ['Aback'],
  };

  final Map<String, List<String>> _antonyms = {
    'Aback': ['Calm', 'Unmoved'],
    'Surprised': ['Calm', 'Indifferent'],
    'Startled': ['Calm'],
  };

  /// NEW: Etymology storage for translations
  final Map<String, String> _translationEtymologies = {
    'Nakigkig': "From root word 'kigkig' (shiver/tremble) with prefix 'na-' indicating completed aspect.",
    'Nagbulag': "Derived from 'bulag' (to be shocked/startled) with infix '-nag-' for completed action.",
    'Nagulat': "From root 'gulat' (to be startled), with prefix 'na-' marking completed aspect.",
    'Nasorpresa': "Borrowed from Spanish 'sorpresa' (surprise), adapted with prefix 'na-' for completed aspect.",
  };

  // Getters
  List<String> get dialects => _dialects;
  int get selectedDialectIndex => _selectedDialectIndex;
  String? get selectedWord => _selectedWord;

  String get selectedDialect => _dialects[_selectedDialectIndex];
  List<String> get currentWordList =>
      List<String>.from(_words[selectedDialect] ?? [])..sort();

  Map<String, String>? getTranslation(String word) => _translations[word];
  String? getDialectTranslation(String word) =>
      _translations[word]?[selectedDialect];

  String? getSampleSentence(String word) =>
      _sampleSentences[word]?[selectedDialect];

  List<String> getSynonyms(String word) => _synonyms[word] ?? [];
  List<String> getAntonyms(String word) => _antonyms[word] ?? [];

  /// NEW: Get etymology for a given translation
  String? getTranslationEtymology(String translation) =>
      _translationEtymologies[translation];

  // Actions
  void selectDialect(int index) {
    _selectedDialectIndex = index;
    notifyListeners();
  }

  void selectWord(String? word) {
    _selectedWord = word;
    notifyListeners();
  }
}