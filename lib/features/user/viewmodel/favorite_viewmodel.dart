import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/favorite_model.dart';
import 'package:tarami_application/core/services/user_activity_servicess.dart';


class FavoriteViewModel extends ChangeNotifier {
  final UserActivityService _userActivityService = UserActivityService();

  List<FavoriteItem> _favoriteItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<FavoriteItem> get favoriteItems => List.unmodifiable(_favoriteItems);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize and load favorite words from Firebase
  Future<void> initialize() async {
    await loadFavoriteWords();
  }

  // Load favorite words from Firebase
  Future<void> loadFavoriteWords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get favorite words from Firebase
      final favoriteWords = await _userActivityService.getFavoriteWords();

      // Convert to FavoriteItem objects
      _favoriteItems = favoriteWords.map((word) => FavoriteItem(word: word)).toList();

      print('Loaded ${_favoriteItems.length} favorite words from Firebase');
    } catch (e) {
      _errorMessage = 'Failed to load favorite words: $e';
      print('Error loading favorite words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add favorite word (called from DictionaryViewModel)
  Future<void> addFavorite(String word) async {
    try {
      // Check if word already exists to prevent duplicates
      if (!_favoriteItems.any((item) => item.word.toLowerCase() == word.toLowerCase())) {
        _favoriteItems.insert(0, FavoriteItem(word: word));
        notifyListeners();

        // Then save to Firebase (doesn't block UI)
        await _userActivityService.addToFavorites(word);

        print('Added "$word" to favorites');
      }
    } catch (e) {
      print('Error adding favorite word: $e');
    }
  }

  // Remove favorite by item
  Future<void> removeFavorite(FavoriteItem itemToRemove) async {
    try {
      _favoriteItems.remove(itemToRemove);
      notifyListeners();

      // Then remove from Firebase
      await _userActivityService.removeFromFavorites(itemToRemove.word);

      print('Removed "${itemToRemove.word}" from favorites');
    } catch (e) {
      print('Error removing favorite word: $e');
    }
  }

  // Remove favorite by index (for your existing UI)
  Future<void> removeFavoriteByIndex(int index) async {
    if (index >= 0 && index < _favoriteItems.length) {
      final itemToRemove = _favoriteItems[index];
      await removeFavorite(itemToRemove);
    }
  }

  // Clear all favorite words
  Future<void> clearAllFavorites() async {
    try {
      // 🔥 Clear local list first
      _favoriteItems.clear();
      notifyListeners();

      // Then clear from Firebase
      await _userActivityService.clearAllFavorites();

      print('Cleared all favorite words');
    } catch (e) {
      print('Error clearing favorite words: $e');
    }
  }

  // Check if a word is in favorites
  bool isFavorite(String word) {
    return _favoriteItems.any((item) => item.word.toLowerCase() == word.toLowerCase());
  }

// Toggle favorite status (non-blocking, optimistic update)
  void toggleFavorite(String word) {
    final isFav = isFavorite(word);

    if (isFav) {
      final itemToRemove = _favoriteItems.firstWhere(
            (item) => item.word.toLowerCase() == word.toLowerCase(),
      );

      // 🔥 Remove locally first
      _favoriteItems.remove(itemToRemove);
      notifyListeners();

      // Firestore update in background
      _userActivityService.removeFromFavorites(itemToRemove.word).catchError((e) {
        print('Error removing favorite: $e');

        // Optional rollback if Firestore fails
        _favoriteItems.insert(0, itemToRemove);
        notifyListeners();
      });

    } else {
      final newItem = FavoriteItem(word: word);

      // 🔥 Add locally first
      _favoriteItems.insert(0, newItem);
      notifyListeners();

      // Firestore update in background
      _userActivityService.addToFavorites(word).catchError((e) {
        print('Error adding favorite: $e');

        // Optional rollback if Firestore fails
        _favoriteItems.removeWhere((item) => item.word == word);
        notifyListeners();
      });
    }
  }

  // Refresh data from Firebase
  Future<void> refresh() async {
    await loadFavoriteWords();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}