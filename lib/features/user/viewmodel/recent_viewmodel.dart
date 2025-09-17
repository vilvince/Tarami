import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/recent_model.dart';
import 'package:tarami_application/core/services/user_activity_servicess.dart';

class RecentViewModel extends ChangeNotifier {
  final UserActivityService _userActivityService = UserActivityService();

  List<RecentItem> _recentItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<RecentItem> get recentItems => List.unmodifiable(_recentItems);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize and load recent words from Firebase
  Future<void> initialize() async {
    await loadRecentWords();
  }

  // Load recent words from Firebase
  Future<void> loadRecentWords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get recent words from Firebase
      final recentData = await _userActivityService.getRecentWords();

      // Convert Firebase data to RecentItem objects
      _recentItems = recentData.map((data) => RecentItem(word: data['word'])).toList();

      print('Loaded ${_recentItems.length} recent words from Firebase');
    } catch (e) {
      _errorMessage = 'Failed to load recent words: $e';
      print('Error loading recent words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add recent word (called from DictionaryViewModel)
  Future<void> addRecent(String word) async {
    try {
      // Check if word already exists to prevent duplicates in UI
      if (!_recentItems.any((item) => item.word.toLowerCase() == word.toLowerCase())) {
        // Add to Firebase (UserActivityService handles this)
        await _userActivityService.addToRecent(word, 'manual');

        // Update local list for immediate UI feedback
        _recentItems.insert(0, RecentItem(word: word)); // Add to beginning
        notifyListeners();

        print('Added "$word" to recent words');
      }
    } catch (e) {
      print('Error adding recent word: $e');
    }
  }

  // Remove recent by item
  Future<void> removeRecent(RecentItem itemToRemove) async {
    try {
      // Remove from Firebase
      await _userActivityService.removeFromRecent(itemToRemove.word);

      // Update local list
      _recentItems.remove(itemToRemove);
      notifyListeners();

      print('Removed "${itemToRemove.word}" from recent words');
    } catch (e) {
      print('Error removing recent word: $e');
    }
  }

  // Remove recent by index (for your existing UI)
  Future<void> removeRecentByIndex(int index) async {
    if (index >= 0 && index < _recentItems.length) {
      final itemToRemove = _recentItems[index];
      await removeRecent(itemToRemove);
    }
  }

  // Clear all recent words
  Future<void> clearAllRecents() async {
    try {
      // Clear from Firebase
      await _userActivityService.clearAllRecent();

      // Update local list
      _recentItems.clear();
      notifyListeners();

      print('Cleared all recent words');
    } catch (e) {
      print('Error clearing recent words: $e');
    }
  }

  // Check if a word is in recent
  bool isRecent(String word) {
    return _recentItems.any((item) => item.word.toLowerCase() == word.toLowerCase());
  }

  // Refresh data from Firebase
  Future<void> refresh() async {
    await loadRecentWords();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}