import 'package:flutter/foundation.dart';
import 'package:tarami_application/features/dictionary/model/dictionary_model.dart';
import 'package:tarami_application/core/services/dictionary_services.dart';


class DictionaryViewModel extends ChangeNotifier {
  final DictionaryService _dictionaryService = DictionaryService();

  // Dialect constants
  final List<String> _dialects = [
    'Central Bikol',
    'West Miraya',
    'East Miraya',
    'Libon Bikol'
  ];

  // State variables
  int _selectedDialectIndex = 0;
  DictionaryEntry? _selectedWordEntry;
  List<DictionaryEntry> _allWords = [];
  List<DictionaryEntry> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _errorMessage;

  // Getters
  List<String> get dialects => _dialects;
  int get selectedDialectIndex => _selectedDialectIndex;
  DictionaryEntry? get selectedWord => _selectedWordEntry;
  String get selectedDialect => _dialects[_selectedDialectIndex];
  List<DictionaryEntry> get allWords => _allWords;
  List<DictionaryEntry> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  // Current word list for UI (returns word strings)
  List<String> get currentWordList {
    final words = _searchQuery.isNotEmpty ? _searchResults : _allWords;
    return words.map((entry) => entry.word).toList()..sort();
  }

  // Initialize the dictionary
  Future<void> initialize() async {
    print('Initializing Dictionary ViewModel...');
    await loadAllWords();
  }

  // Load all words from Firebase
  Future<void> loadAllWords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading words from Firebase...');
      _allWords = await _dictionaryService.getAllWords();
      print('Loaded ${_allWords.length} words successfully');
    } catch (e) {
      _errorMessage = 'Failed to load dictionary: $e';
      print('Error loading words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search for words
  Future<void> searchWords(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Searching for: $_searchQuery');
      _searchResults = await _dictionaryService.searchWords(_searchQuery);
      print('Found ${_searchResults.length} results');
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      print('Error searching: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Select a word to view details
  void selectWord(String? wordName) {
    if (wordName == null) {
      _selectedWordEntry = null;
      notifyListeners();
      return;
    }

    try {
      // Find the word in current results
      final words = _searchQuery.isNotEmpty ? _searchResults : _allWords;
      _selectedWordEntry = words.firstWhere(
            (entry) => entry.word.toLowerCase() == wordName.toLowerCase(),
      );
      print('Selected word: ${_selectedWordEntry?.word}');
    } catch (e) {
      print('Error selecting word: $e');
      _selectedWordEntry = null;
    }

    notifyListeners();
  }

  // Select dialect tab
  void selectDialect(int index) {
    if (index >= 0 && index < _dialects.length) {
      _selectedDialectIndex = index;
      notifyListeners();
    }
  }

  // Helper methods for word details (these match your existing UI calls)

  String? getDialectTranslation(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      return _selectedWordEntry?.getTranslationForDialect(_getDialectKey(selectedDialect))
          ?? 'No translation available';
    }
    return null;
  }


  List<String> getSynonyms(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      final rawSynonyms = _selectedWordEntry?.synonyms ?? [];
      final cleaned = rawSynonyms
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet() // remove duplicates
          .toList();
      return cleaned;
    }
    return [];
  }



  // Additional helper methods for your UI
  String getPhoneticsForDialect(String word) {
    // If no word is selected, fallback
    if (_selectedWordEntry?.word.toLowerCase() != word.toLowerCase()) {
      return "/${word.toLowerCase()}/";
    }

    // Normalize dialect key (important: UI shows "Central Bikol" but DB is "central_bikol")
    final dialectKey = _getDialectKey(selectedDialect);

    // Fetch phonetics from model
    final phonetics = _selectedWordEntry?.getPhoneticsForDialect(dialectKey);

    // If phonetics exist and not empty, return them; else fallback
    return (phonetics != null && phonetics.trim().isNotEmpty)
        ? phonetics
        : "/${word.toLowerCase()}/";
  }


  String? getPartOfSpeech(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      return _selectedWordEntry?.partOfSpeech ?? 'Unknown';
    }
    return null;
  }

  String? getDefinition(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      return _selectedWordEntry?.definition ?? 'Definition not available';
    }
    return null;
  }

  String? getTagalogTranslation(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      return _selectedWordEntry?.tagalog ?? 'Not available';
    }
    return null;
  }

  String getSampleSentenceInEnglish(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      final sentence = _selectedWordEntry?.exampleSentence;
      if (sentence != null && sentence.trim().isNotEmpty) {
        return sentence;
      }
    }
    return 'No sample sentence available';
  }

  String getSampleSentence(String word) {
    if (_selectedWordEntry?.word.toLowerCase() == word.toLowerCase()) {
      final sentence = _selectedWordEntry?.getSampleSentenceForDialect(
        _getDialectKey(selectedDialect),
      );
      if (sentence != null && sentence.trim().isNotEmpty) {
        return sentence;
      }
    }
    return 'No sample sentence available';
  }



  // Convert display dialect name to database key
  String _getDialectKey(String dialectName) {
    switch (dialectName) {
      case 'Central Bikol':
        return 'central_bikol';
      case 'West Miraya':
        return 'west_miraya';
      case 'East Miraya':
        return 'east_miraya';
      case 'Libon Bikol':
        return 'libon_bikol';
      default:
        return 'central_bikol';
    }
  }

  // Clear error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAllWords();
  }

  final Set<String> audioWords = {
    "breeze", // test word with audio
  };

  bool hasAudio(String word) {
    return audioWords.contains(word.toLowerCase());
  }

}