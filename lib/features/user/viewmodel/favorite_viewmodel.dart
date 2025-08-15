import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/favorite_model.dart'; // Adjust import path

class FavoriteViewModel extends ChangeNotifier {
  // Using a Set can be good if you want to ensure no duplicate words by default,
  // but List is fine if your logic already handles this or if order matters strictly
  // and duplicates are allowed (though for favorite words, duplicates are unlikely desired).
  // Let's stick to List<FavoriteItem> to map closer to your original List<String>.
  final List<FavoriteItem> _favoriteItems = [
    // Initial dummy data, similar to your original favoriteWords
    FavoriteItem(word: 'apple'),
    FavoriteItem(word: 'banana'),
    FavoriteItem(word: 'mango'),
    FavoriteItem(word: 'pineapple'),
    FavoriteItem(word: 'orange'),
    FavoriteItem(word: 'strawberry'),
    FavoriteItem(word: 'grape'),
    FavoriteItem(word: 'watermelon'),
    FavoriteItem(word: 'melon'),
    FavoriteItem(word: 'sit'),
  ];

  List<FavoriteItem> get favoriteItems => List.unmodifiable(_favoriteItems); // Provide an unmodifiable view

  // In a real app, you'd likely load favorites from persistence (e.g., SharedPreferences, SQLite)
  // in the constructor or an init method.

  void addFavorite(String word) {
    // Prevent adding duplicates if the word already exists
    if (!_favoriteItems.any((item) => item.word == word)) {
      _favoriteItems.add(FavoriteItem(word: word));
      notifyListeners(); // Notify UI to rebuild
      // In a real app, also save to persistence here
    }
  }

  void removeFavorite(FavoriteItem itemToRemove) {
    _favoriteItems.remove(itemToRemove);
    notifyListeners();
    // In a real app, also update persistence here
  }

  void removeFavoriteByIndex(int index) {
    if (index >= 0 && index < _favoriteItems.length) {
      _favoriteItems.removeAt(index);
      notifyListeners();
      // In a real app, also update persistence here
    }
  }

  void clearAllFavorites() {
    _favoriteItems.clear();
    notifyListeners();
    // In a real app, also update persistence here
  }

  // Example of checking if a word is already a favorite
  bool isFavorite(String word) {
    return _favoriteItems.any((item) => item.word == word);
  }
}
