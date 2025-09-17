import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // RECENT WORDS FUNCTIONALITY
  /// Add a word to user's recent searches/views
  Future<void> addToRecent(String word, String type) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('recent_words')
          .doc(word.toLowerCase())
          .set({
        'word': word,
        'type': type, // 'search' or 'view'
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Added "$word" to recent ($type)');
    } catch (e) {
      print('Error adding to recent: $e');
    }
  }

  /// Get user's recent words (limit to last 50)
  Future<List<Map<String, dynamic>>> getRecentWords() async {
    if (_currentUserId == null) return [];

    try {
      final query = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('recent_words')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'word': data['word'],
          'type': data['type'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      print('Error getting recent words: $e');
      return [];
    }
  }

  // FAVORITES FUNCTIONALITY
  /// Add word to favorites
  Future<void> addToFavorites(String word) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorite_words')
          .doc(word.toLowerCase())
          .set({
        'word': word,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Added "$word" to favorites');
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  /// Remove word from favorites
  Future<void> removeFromFavorites(String word) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorite_words')
          .doc(word.toLowerCase())
          .delete();

      print('Removed "$word" from favorites');
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  /// Check if word is in favorites
  Future<bool> isFavorite(String word) async {
    if (_currentUserId == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorite_words')
          .doc(word.toLowerCase())
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Get all favorite words
  Future<List<String>> getFavoriteWords() async {
    if (_currentUserId == null) return [];

    try {
      final query = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorite_words')
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs.map((doc) => doc.data()['word'] as String).toList();
    } catch (e) {
      print('Error getting favorite words: $e');
      return [];
    }
  }

  /// Toggle favorite status (add if not favorite, remove if favorite)
  Future<bool> toggleFavorite(String word) async {
    final isFav = await isFavorite(word);

    if (isFav) {
      await removeFromFavorites(word);
      return false; // Now not favorite
    } else {
      await addToFavorites(word);
      return true; // Now favorite
    }
  }

  // ADDITIONAL METHODS FOR VIEWMODELS

  /// Remove word from recent
  Future<void> removeFromRecent(String word) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('recent_words')
          .doc(word.toLowerCase())
          .delete();

      print('Removed "$word" from recent');
    } catch (e) {
      print('Error removing from recent: $e');
    }
  }

  /// Clear all recent words
  Future<void> clearAllRecent() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();

      final recentCollection = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('recent_words')
          .get();

      for (var doc in recentCollection.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Cleared all recent words');
    } catch (e) {
      print('Error clearing all recent: $e');
    }
  }

  /// Clear all favorite words
  Future<void> clearAllFavorites() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();

      final favoritesCollection = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('favorite_words')
          .get();

      for (var doc in favoritesCollection.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Cleared all favorite words');
    } catch (e) {
      print('Error clearing all favorites: $e');
    }
  }
}