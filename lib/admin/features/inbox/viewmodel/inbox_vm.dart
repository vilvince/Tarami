import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../AdminServices/admin_inbox_service.dart'; // Adjust path if needed

class InboxVM extends ChangeNotifier {
  final AdminSubmissionService _submissionService = AdminSubmissionService();
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  // State
  List<Map<String, dynamic>> _allSubmissions = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedFilter = "Pending"; // Default to "Pending"
  int _currentPage = 1;
  int _rowsPerPage = 10;

  // Getters for the UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;

  /// Returns the correctly filtered list of submissions based on the selected tab.
  List<Map<String, dynamic>> get filteredItems {
    switch (_selectedFilter) {
      case "Pending":
        return _allSubmissions.where((item) => item['status'] == 'pending').toList();
      case "Reviewed":
        return _allSubmissions.where((item) => ['approved', 'denied', 'flagged'].contains(item['status'])).toList();
      case "All":
      default:
        return _allSubmissions;
    }
  }

  /// Returns the portion of the filtered list for the current page.
  List<Map<String, dynamic>> get paginatedItems {
    final items = filteredItems;
    if (items.isEmpty) return [];

    final startIndex = (_currentPage - 1) * _rowsPerPage;
    if (startIndex >= items.length) return [];

    final endIndex = min(startIndex + _rowsPerPage, items.length);
    return items.sublist(startIndex, endIndex);
  }

  /// Calculates the total number of pages based on the filtered list.
  int get totalPages => (filteredItems.isEmpty) ? 1 : (filteredItems.length / _rowsPerPage).ceil();

  InboxVM() {
    _listenToSubmissions();
  }

  void _listenToSubmissions() {
    _subscription?.cancel(); // Cancel any existing subscription first
    _isLoading = true;
    notifyListeners();

    // We only need one stream that gets ALL submissions. Filtering is done on the client.
    _subscription = _submissionService.getAllSubmissions().listen(
          (submissions) {
        _allSubmissions = submissions;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = "Failed to load inbox: $error";
        notifyListeners();
      },
    );
  }

  // --- UI Actions ---

  void setFilter(String filter) {
    _selectedFilter = filter;
    _currentPage = 1; // Reset to the first page when filter changes
    notifyListeners();
  }

  void setRowsPerPage(int value) {
    _rowsPerPage = value;
    _currentPage = 1;
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

  void goToPage(int page) {
    _currentPage = page.clamp(1, totalPages);
    notifyListeners();
  }

  // --- Database Actions (Pass-through to Service) ---

  Future<Map<String, dynamic>> approveSubmission(String submissionId) =>
      _submissionService.approveSubmission(submissionId);

  Future<Map<String, dynamic>> denySubmission(String submissionId) =>
      _submissionService.denySubmission(submissionId);

  Future<Map<String, dynamic>> flagSubmission(String submissionId) =>
      _submissionService.flagSubmission(submissionId);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}