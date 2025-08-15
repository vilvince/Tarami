import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/recent_model.dart'; // Adjust import path

class RecentViewModel extends ChangeNotifier {
  // Using a Set can be good if you want to ensure no duplicate words by default,
  // but List is fine if your logic already handles this or if order matters strictly
  // and duplicates are allowed (though for favorite words, duplicates are unlikely desired).
  // Let's stick to List<FavoriteItem> to map closer to your original List<String>.
  final List<RecentItem> _recentItems = [
    // Initial dummy data, similar to your original favoriteWords
    RecentItem(word: 'apple'),
    RecentItem(word: 'banana'),
    RecentItem(word: 'mango'),
    RecentItem(word: 'pineapple'),
    RecentItem(word: 'orange'),
    RecentItem(word: 'strawberry'),
    RecentItem(word: 'grape'),
    RecentItem(word: 'watermelon'),
    RecentItem(word: 'melon'),
    RecentItem(word: 'sit'),
  ];

  List<RecentItem> get recentItems => List.unmodifiable(_recentItems); // Provide an unmodifiable view

  // In a real app, you'd likely load favorites from persistence (e.g., SharedPreferences, SQLite)
  // in the constructor or an init method.

  void addRecent(String word) {
    // Prevent adding duplicates if the word already exists
    if (!_recentItems.any((item) => item.word == word)) {
      _recentItems.add(RecentItem(word: word));
      notifyListeners(); // Notify UI to rebuild
      // In a real app, also save to persistence here
    }
  }

  void removeRecent(RecentItem itemToRemove) {
    _recentItems.remove(itemToRemove);
    notifyListeners();
    // In a real app, also update persistence here
  }

  void removeRecentByIndex(int index) {
    if (index >= 0 && index < _recentItems.length) {
      _recentItems.removeAt(index);
      notifyListeners();
      // In a real app, also update persistence here
    }
  }

  void clearAllRecents() {
    _recentItems.clear();
    notifyListeners();
    // In a real app, also update persistence here
  }

  // Example of checking if a word is already a favorite
  bool isRecent(String word) {
    return _recentItems.any((item) => item.word == word);
  }
}
