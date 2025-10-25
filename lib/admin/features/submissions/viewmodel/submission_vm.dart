import 'dart:async';
import 'package:flutter/material.dart';
import '../data/submission_model.dart';
import '../../../AdminServices/admin_submissions_service.dart';
import 'dart:math';

class SubmissionVM extends ChangeNotifier {
  final AdminSubmissionsService _service = AdminSubmissionsService();
  StreamSubscription<List<SubmissionModel>>? _subscription;

  //state
  List<SubmissionModel> _allSubmissions = [];
  bool _isLoading = true;
  String? _error;

  String selectedFilter = "Approved";
  int currentPage = 1;
  int rowsPerPage = 5;

  //Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SubmissionModel> get filteredItems {
    return _allSubmissions
    .where((item) => item.status.toLowerCase() == selectedFilter.toLowerCase())
    .toList();
  }

  List<SubmissionModel> get paginatedItems {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return filteredItems.sublist(
      start,
      end > filteredItems.length ? filteredItems.length : end,
    );
  }

  int get totalPages =>
      (filteredItems.length / rowsPerPage).ceil().clamp(1, double.infinity).toInt();


  SubmissionVM(){
    _listenToSubmissions();
  }

  void _listenToSubmissions(){
    _isLoading = true;
    notifyListeners();
    _subscription = _service.getReviewedSubmissionStream().listen(
            (submissions) {
              _allSubmissions = submissions;
              _isLoading = false;
              _error = null;
              notifyListeners();
            },
              onError: (e){
              _isLoading = false;
              _error = "Failed to load submissions: $e";
              notifyListeners();
              },
    );
  }


  void setFilter(String filter) {
    selectedFilter = filter;
    currentPage = 1;
    notifyListeners();
  }

  void setRowsPerPage(int value) {
    rowsPerPage = value;
    currentPage = 1;
    notifyListeners();
  }

  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }

  void prevPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
      notifyListeners();
    }
  }
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
