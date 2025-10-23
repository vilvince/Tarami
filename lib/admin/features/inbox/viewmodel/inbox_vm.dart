import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tarami_application/admin/AdminServices/admin_inbox_service.dart'; // Update path

class InboxVM extends ChangeNotifier {
  final AdminSubmissionService _submissionService = AdminSubmissionService();

  // State
  String _selectedFilter = "All";
  int _currentPage = 1;
  int _rowsPerPage = 10;

  // Data - populated from Firestore streams
  List<Map<String, dynamic>> _allSubmissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get selectedFilter => _selectedFilter;
  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor - start listening to submissions
  InboxVM() {
    _loadSubmissions();
  }

  // Load submissions based on filter
  void _loadSubmissions() {
    _isLoading = true;
    notifyListeners();

    try {
      switch (_selectedFilter) {
        case "Pending":
          _submissionService.getPendingSubmissions().listen((submissions) {
            _allSubmissions = submissions;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          });
          break;

        case "Reviewed":
          _submissionService.getReviewedSubmissions().listen((submissions) {
            _allSubmissions = submissions;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          });
          break;

        default: // "All"
          _submissionService.getAllSubmissions().listen((submissions) {
            _allSubmissions = submissions;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          });
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load submissions: $e';
      notifyListeners();
    }
  }

  // Filtered items based on current selection
  List<Map<String, dynamic>> get filteredItems => _allSubmissions;

  // Total pages
  int get totalPages {
    final length = filteredItems.length;
    if (length == 0) return 1;
    return ((length + _rowsPerPage - 1) ~/ _rowsPerPage);
  }

  // Paginated items for current page
  List<Map<String, dynamic>> get paginatedItems {
    final items = filteredItems;
    if (items.isEmpty) return [];

    // Ensure current page within bounds
    final pages = totalPages;
    if (_currentPage < 1) _currentPage = 1;
    if (_currentPage > pages) _currentPage = pages;

    final start = (_currentPage - 1) * _rowsPerPage;
    final end = math.min(start + _rowsPerPage, items.length);
    if (start >= items.length) return [];
    return items.sublist(start, end);
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  /// Change filter (All, Pending, Reviewed)
  void setFilter(String filter) {
    _selectedFilter = filter;
    _currentPage = 1;
    _loadSubmissions(); // Reload data with new filter
  }

  /// Approve submission
  Future<Map<String, dynamic>> approveSubmission(String submissionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _submissionService.approveSubmission(submissionId);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Deny submission
  Future<Map<String, dynamic>> denySubmission(
      String submissionId, {
        String? reason,
      }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _submissionService.denySubmission(
        submissionId,
        reason: reason,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Flag submission
  Future<Map<String, dynamic>> flagSubmission(
      String submissionId, {
        String? reason,
      }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _submissionService.flagSubmission(
        submissionId,
        reason: reason,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ==========================================
  // PAGINATION
  // ==========================================

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
    final p = page.clamp(1, totalPages);
    if (p != _currentPage) {
      _currentPage = p;
      notifyListeners();
    }
  }

  void updateRowsPerPage(int value) {
    _rowsPerPage = value;
    _currentPage = 1;
    notifyListeners();
  }

  int get totalItemsCount => filteredItems.length;
}