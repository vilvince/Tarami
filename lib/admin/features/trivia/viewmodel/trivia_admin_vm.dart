import 'dart:async';
import 'package:flutter/material.dart';
import '../../../AdminServices/admin_trivia_service.dart';
import '../data/trivia_model.dart';

class TriviaAdminVM extends ChangeNotifier {
  final TriviaService _triviaService = TriviaService();
  StreamSubscription<List<Trivia>>? _triviaSubscription;

  // State variables
  List<Trivia> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Trivia> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor - start listening once
  TriviaAdminVM() {
    _subscribe();
  }

  void _subscribe() {
    _triviaSubscription = _triviaService.getTriviaStream().listen(
          (list) {
        // ✅ Skip rebuild if no actual change
        if (_listsEqual(_items, list)) return;

        _items = list;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = _formatErrorMessage(error);
        notifyListeners();
      },
    );
  }

  /// Compare old vs new list to avoid unnecessary rebuilds
  bool _listsEqual(List<Trivia> a, List<Trivia> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].text != b[i].text) return false;
    }
    return true;
  }

  String _formatErrorMessage(dynamic error) {
    final e = error.toString().toLowerCase();
    if (e.contains('permission')) return 'Permission denied.';
    if (e.contains('network')) return 'Network error.';
    return 'Failed: $error';
  }

  // ---------------- CRUD ----------------

  Future<void> addTrivia(String text) async {
    try {
      await _triviaService.addTrivia(text.trim());
    } catch (e) {
      _errorMessage = 'Failed to add: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTrivia(String id, String text) async {
    try {
      await _triviaService.updateTrivia(id, text.trim());
    } catch (e) {
      _errorMessage = 'Failed to update: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTrivia(String id) async {
    try {
      await _triviaService.deleteTrivia(id);
    } catch (e) {
      _errorMessage = 'Failed to delete: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Optional manual refresh
  void reload() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    _triviaSubscription?.cancel();
    _subscribe();
  }

  @override
  void dispose() {
    _triviaSubscription?.cancel();
    super.dispose();
  }
}
