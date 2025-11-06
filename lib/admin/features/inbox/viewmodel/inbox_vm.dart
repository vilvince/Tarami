import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../AdminServices/admin_inbox_service.dart'; // Adjust path if needed
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String _selectedDateRange = "Month";

  // Getters for the UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;
  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;
  String get selectedDateRange => _selectedDateRange;


  /// Returns the correctly filtered list of submissions based on the selected tab.
  List<Map<String, dynamic>> get filteredItems {
    List<Map<String, dynamic>> statusFiltered;
    String dateFieldToUse;

    // --- First, filter by status ---
    switch (_selectedFilter) {
      case "Pending":
        statusFiltered = _allSubmissions.where((item) => item['status'] == 'pending').toList();
        dateFieldToUse = 'date_submitted';
        break;
      case "Reviewed":
        statusFiltered = _allSubmissions.where((item) => ['approved', 'denied', 'flagged'].contains(item['status'])).toList();
        dateFieldToUse = 'reviewed_at';
        break;
      case "All":
      default:
        statusFiltered = _allSubmissions;
        dateFieldToUse = 'date_submitted';
    }

    // --- Second, filter the result by date range ---
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedDateRange) {
      case "Month":
        startDate = now.subtract(const Duration(days: 30));
        break;
      case "Year":
        startDate = now.subtract(const Duration(days: 365));
        break;
      case "Week":
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    final dateFiltered = statusFiltered.where((item) {
      final dateDynamic = item[dateFieldToUse]; // Use the correct date field for filtering
      if (dateDynamic is Timestamp) {
        final date = dateDynamic.toDate();
        return date.isAfter(startDate);
      }
      return false; // Don't include items with invalid dates
    }).toList();

    // 3. Sort the final list
    // This ensures the correct sort order is applied *after* all filtering.
    dateFiltered.sort((a, b) {
      final dateA = a[dateFieldToUse] as Timestamp?;
      final dateB = b[dateFieldToUse] as Timestamp?;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // Put nulls at the end
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); // Newest first
    });

    return dateFiltered;
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

  void setDateRangeFilter(String range) {
    _selectedDateRange = range;
    _currentPage = 1; // Reset pagination
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

  Future<Map<String, dynamic>> denySubmission(String submissionId, {String? reason}) =>
      _submissionService.denySubmission(submissionId, reason: reason);

  Future<Map<String, dynamic>> flagSubmission(String submissionId, {String? reason}) =>
      _submissionService.flagSubmission(submissionId, reason: reason);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}