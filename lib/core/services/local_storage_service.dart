// Create a new file: lib/services/local_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'connectivity_service.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorites';
  static const String _searchHistoryKey = 'search_history';

  final ConnectivityService _connectivityService = ConnectivityService();

  // ===== FAVORITES =====

  // Get favorites from local storage
  Future<List<String>> getFavoritesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesJson;
  }

  // Add favorite locally
  Future<void> addFavoriteLocal(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (!favorites.contains(wordId)) {
      favorites.add(wordId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  // Remove favorite locally
  Future<void> removeFavoriteLocal(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.remove(wordId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Toggle favorite (works offline)
  Future<void> toggleFavorite(String wordId) async {
    final favorites = await getFavoritesLocal();
    final isFavorited = favorites.contains(wordId);

    if (isFavorited) {
      await removeFavoriteLocal(wordId);
    } else {
      await addFavoriteLocal(wordId);
    }

    // Sync with Firestore if online
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (hasInternet) {
      await _syncFavoriteToFirestore(wordId, !isFavorited);
    }
  }

  // Sync favorite to Firestore
  Future<void> _syncFavoriteToFirestore(String wordId, bool isFavorite) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(wordId);

    if (isFavorite) {
      await favRef.set({
        'word_id': wordId,
        'favorited_at': FieldValue.serverTimestamp(),
      });
    } else {
      await favRef.delete();
    }
  }

  // Sync all local favorites to Firestore (call this when going online)
  Future<void> syncFavoritesToFirestore() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final localFavorites = await getFavoritesLocal();

    // Get Firestore favorites
    final firestoreFavs = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    final firestoreFavIds = firestoreFavs.docs.map((doc) => doc.id).toList();

    // Add local favorites not in Firestore
    for (String wordId in localFavorites) {
      if (!firestoreFavIds.contains(wordId)) {
        await _syncFavoriteToFirestore(wordId, true);
      }
    }
  }

  // Load favorites from Firestore to local (call on app start if online)
  Future<void> loadFavoritesFromFirestore() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  // ===== SEARCH HISTORY =====

  // Get search history from local storage
  Future<List<String>> getSearchHistoryLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  // Add to search history (works offline)
  Future<void> addSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];

    // Remove if already exists (to move to top)
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only last 20 searches
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }

    await prefs.setStringList(_searchHistoryKey, history);

    // Sync with Firestore if online
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (hasInternet) {
      await _syncSearchHistoryToFirestore(query);
    }
  }

  // Clear search history
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);

    // Clear from Firestore if online
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (hasInternet) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final searchHistoryRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('search_history');

        final docs = await searchHistoryRef.get();
        for (var doc in docs.docs) {
          await doc.reference.delete();
        }
      }
    }
  }

  // Sync search history to Firestore
  Future<void> _syncSearchHistoryToFirestore(String query) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('search_history')
        .add({
      'query': query,
      'searched_at': FieldValue.serverTimestamp(),
    });
  }
}