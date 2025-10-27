import 'dart:async';
import 'package:flutter/material.dart';
import '../data/user_model.dart';
import '../../../AdminServices/admin_user_management_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //
import 'dart:math';

class UserVM extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _allUsers = []; // Stores the complete list of users
  bool _isLoading = true;
  String? _error;

  // Pagination State
  int _rowsPerPage = 5;
  int _currentPage = 1;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get rowsPerPage => _rowsPerPage;
  int get currentPage => _currentPage;

  // Getter for the total number of pages
  int get totalPages {
    if (_allUsers.isEmpty) return 1;
    return (_allUsers.length / _rowsPerPage).ceil();
  }

  // Getter for the users on the CURRENT page
  List<UserModel> get paginatedUsers {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= _allUsers.length) return [];
    final endIndex = min(startIndex + _rowsPerPage, _allUsers.length);
    return _allUsers.sublist(startIndex, endIndex);
  }

  UserVM() {
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allUsers = await _userService.fetchAllUsersWithSubmissionCount();
      // Sort alphabetically once, right after fetching.
      _allUsers.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Pagination Actions ---
  void setRowsPerPage(int value) {
    _rowsPerPage = value;
    _currentPage = 1; // Reset to the first page
    notifyListeners();
  }

  void goToPage(int pageNumber) {
    _currentPage = pageNumber.clamp(1, totalPages);
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

// --- Delete User (Seamless - No Loading Spinner) ---
  Future<bool> deleteUser(UserModel user) async {
    try {
      // Store the user temporarily in case we need to rollback
      final deletedUser = user;
      final deletedIndex = _allUsers.indexWhere((u) => u.id == user.id);

      // OPTIMISTIC UPDATE: Remove from UI immediately (instant feedback)
      _allUsers.removeWhere((u) => u.id == user.id);

      // Adjust current page if needed (if we deleted the last item on a page)
      if (paginatedUsers.isEmpty && _currentPage > 1) {
        _currentPage--;
      }

      notifyListeners(); // Update UI instantly

      // Delete from Firebase in the background
      await _userService.deleteUser(user.id!);

      return true;
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';

      // ROLLBACK: If deletion fails, refresh the list to restore the user
      await _loadAllUsers();

      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}