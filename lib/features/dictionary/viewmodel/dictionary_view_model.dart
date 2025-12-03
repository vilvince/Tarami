import 'package:flutter/foundation.dart';
import 'package:tarami_application/features/dictionary/model/dictionary_model.dart';
import 'package:tarami_application/core/services/dictionary_services.dart';
import 'package:tarami_application/core/services/user_activity_servicess.dart';
import 'package:tarami_application/core/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';

class DictionaryViewModel extends ChangeNotifier {
  final DictionaryService _dictionaryService = DictionaryService();
  final UserActivityService _userActivityService = UserActivityService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final AudioPlayer _audioPlayer = AudioPlayer();


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

  // Add favorites state
  Set<String> _favoriteWords = {};
  bool _isLoadingFavorites = false;

  // Local storage key
  static const String _favoritesKey = 'offline_favorites';


  // ✅ NEW: Track offline pending favorites
  Set<String> _pendingOfflineFavorites = {};

  // ✅ NEW: Track connectivity state
  bool _isOnline = true;


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
  Set<String> get favoriteWords => _favoriteWords;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isOnline => _isOnline;


  // Current word list for UI (returns word strings) - FILTERED BY DIALECT
  List<String> get currentWordList {
    final words = _searchQuery.isNotEmpty ? _searchResults : _allWords;

    // Filter words that have translations for the selected dialect
    final dialectKey = _getDialectKey(selectedDialect);
    final filteredWords = words.where((entry) {
      // Check if this word has a translation for the current dialect
      final translation = entry.getTranslationForDialect(dialectKey);
      return translation != null && translation.trim().isNotEmpty;
    }).toList();

    return filteredWords.map((entry) => entry.word).toList()..sort();
  }

  // Initialize the dictionary
  Future<void> initialize() async {
    print('Initializing Dictionary ViewModel...');

    // Check connectivity first
    _isOnline = await _connectivityService.isConnected();

    await Future.wait([
      loadAllWords(),
      loadFavorites(),
      _loadOfflinePendingFavorites(),
    ]);
    // ✅ Start monitoring connectivity
    _listenToConnectivity();
  }


  // ✅ Listen for connectivity changes
  void _listenToConnectivity() {
    _connectivityService.connectivityStream.listen((result) async {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();

      if (wasOffline && _isOnline) {
        print('🌐 Back online — syncing offline favorites...');
        await syncFavoritesWhenOnline();
      } else if (!_isOnline) {
        print('⚠️ Went offline');
      }
    });
  }

  // ✅ Load offline pending favorites from local storage
  Future<void> _loadOfflinePendingFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineList = prefs.getStringList('pending_offline_favorites') ?? [];
    _pendingOfflineFavorites = offlineList.toSet();
    print('Loaded ${_pendingOfflineFavorites.length} pending offline favorites');
  }

  // ✅ Save pending offline favorites locally
  Future<void> _saveOfflinePendingFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pending_offline_favorites', _pendingOfflineFavorites.toList());
  }

  // ✅ Sync offline favorites when online again
  Future<void> syncFavoritesWhenOnline() async {
    if (_pendingOfflineFavorites.isEmpty) {
      print('No offline favorites to sync');
      return;
    }

    for (final word in _pendingOfflineFavorites) {
      try {
        await _userActivityService.toggleFavorite(word);
        print('Synced offline favorite: $word');
      } catch (e) {
        print('Failed to sync $word: $e');
      }
    }

    _pendingOfflineFavorites.clear();
    await _saveOfflinePendingFavorites();
    await loadFavorites(); // refresh from server
    notifyListeners();
  }


  // Load all words from Firebase
  Future<void> loadAllWords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading words from Firebase...');

      // Check if online before attempting to fetch
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        print('⚠️ Offline - Loading from Firestore cache only');
        // Force load from cache with timeout
        try {
          _allWords = await _dictionaryService.getAllWords()
              .timeout(Duration(seconds: 2)); // Short timeout for cache
          print('Loaded ${_allWords.length} words from cache');
        }catch (e) {
          print('No cached words available: $e');
          _errorMessage = 'No cached words. Connect to internet to load dictionary.';
        }
      } else {
        print('🌐 Online - Loading from Firestore');
        // Normal fetch when online
        _allWords = await _dictionaryService.getAllWords();
        print('Loaded ${_allWords.length} words successfully');
      }
    }catch (e) {
      _errorMessage = 'Failed to load dictionary: $e';
      print('Error loading words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's favorite words
  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    notifyListeners();

    try {
      // Check connectivity first
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        print('⚠️ Offline - Loading favorites from local storage');
        // Load from local storage
        final prefs = await SharedPreferences.getInstance();
        final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
        _favoriteWords = favoritesList.map((w) => w.toLowerCase()).toSet();
        print('Loaded ${_favoriteWords.length} favorites from local storage');
      }else {
        print('🌐 Online - Loading favorites from Firestore');
        // Load from Firestore
        final favorites = await _userActivityService.getFavoriteWords();
        _favoriteWords = favorites.map((word) => word.toLowerCase()).toSet();
        // Save to local storage for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_favoritesKey, _favoriteWords.toList());
        print('Loaded ${_favoriteWords.length} favorite words');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
        _favoriteWords = favoritesList.map((w) => w.toLowerCase()).toSet();
        print('Loaded ${_favoriteWords.length} favorites from local storage (fallback)');
      } catch (localError) {
        print('Failed to load favorites from local storage: $localError');
      }
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  // Search for words - NO LONGER ADDS TO RECENT
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

      // Check connectivity for search timeout
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // Use shorter timeout when offline (search from cache)
        _searchResults = await _dictionaryService.searchWords(_searchQuery)
            .timeout(Duration(seconds: 2));
      } else {
        _searchResults = await _dictionaryService.searchWords(_searchQuery);
      }
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
  void selectWord(String? wordName) async {
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

      // ONLY add to recent if the user clicked from SEARCH RESULTS (not from browsing all words)
      if (_searchQuery.isNotEmpty) {
        await _userActivityService.addToRecent(wordName, 'view');
        print('Added "$wordName" to recent (from search results)');
      } else {
        print('Did NOT add "$wordName" to recent (browsing mode)');
      }

    } catch (e) {
      print('Error selecting word: $e');
      _selectedWordEntry = null;
    }

    notifyListeners();
  }

  // Toggle favorite status for a word
  Future<void> toggleFavorite(String word) async {
    final lowerWord = word.toLowerCase();
    try {
      final hasConnection = await _connectivityService.isConnected();

      if (!hasConnection) {
        print('Offline — storing favorite locally: $lowerWord');
        // Save offline
        if (_favoriteWords.contains(lowerWord)) {
          _favoriteWords.remove(lowerWord);
        } else {
          _favoriteWords.add(lowerWord);
        }
        // ✅ Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_favoritesKey, _favoriteWords.toList());

        _pendingOfflineFavorites.add(lowerWord);
        await _saveOfflinePendingFavorites();

        notifyListeners();
        return;
      }
      // Online - sync to Firestore
      final newStatus = await _userActivityService.toggleFavorite(word);

      if (newStatus) {
        _favoriteWords.add(lowerWord);
      } else {
        _favoriteWords.remove(lowerWord);
      }

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteWords.toList());

      notifyListeners();
      print('Toggled favorite for "$word" - now ${newStatus ? 'favorited' : 'unfavorited'}');
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Check if word is favorite
  bool isFavorite(String word) {
    return _favoriteWords.contains(word.toLowerCase());
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
    await Future.wait([
      loadAllWords(),
      loadFavorites(),
    ]);
  }

  void resetState() {
    _selectedWordEntry = null;
    _searchQuery = '';      // Clear the query string
    _searchResults = [];    // Clear the results list
    _isSearching = false;
    _errorMessage = null;
    notifyListeners();      // Tell the UI to update
  }

  Future<void> playAudio(String? url) async{
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      // If offline, throw an error with a user-friendly message.
      throw Exception("An internet connection is required to play audio.");
    }
    if(url == null || url.isEmpty){
      print("Audio Url is empty, cannot play.");
      return;
    }try{
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    }catch(e){
      print("Error playing audio: $e");
      _errorMessage = "Could not play audio.";
      notifyListeners();
    }
  }

  String? getAudioUrlForSelectedDialect(){
    if(_selectedWordEntry == null) return null;
    try{
      final dialectKey = _getDialectKey(selectedDialect);
      return _selectedWordEntry!.translations
          .firstWhere((t) => t.dialect == dialectKey)
          .audioUrl;
    }catch(e){
      return null;
    }
  }
}