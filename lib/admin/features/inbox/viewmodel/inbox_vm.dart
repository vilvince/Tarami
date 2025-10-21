// inbox_vm.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/inbox_model.dart';

class InboxVM extends ChangeNotifier {
  // Sample data — replace / fetch from backend as needed
  final List<InboxItem> _allItems = [
    InboxItem(
      email: "example@email.com",
      submittedWord: "Feet",
      dialect: "Central Bikol",
      translation: "Bitis",
      date: "03/25/2025",
      partOfSpeech: "Noun",
      status: "Reviewed",
    ),
    InboxItem(
      email: "example2@email.com",
      submittedWord: "Feet",
      dialect: "West Miraya",
      translation: "Bitis",
      date: "03/25/2025",
      partOfSpeech: "Noun",
      status: "Pending",
    ),
    // add more test items as needed...
  ];

  String _selectedFilter = "All";
  int _currentPage = 1;
  int _rowsPerPage = 10;

  // public getters
  String get selectedFilter => _selectedFilter;
  int get currentPage => _currentPage;
  int get rowsPerPage => _rowsPerPage;

  // filtered list according to filter selection
  List<InboxItem> get filteredItems {
    if (_selectedFilter == "All") return List<InboxItem>.from(_allItems);
    return _allItems.where((it) => it.status == _selectedFilter).toList();
  }

  // total pages (always >= 1)
  int get totalPages {
    final length = filteredItems.length;
    if (length == 0) return 1;
    return ((length + _rowsPerPage - 1) ~/ _rowsPerPage);
  }

  // safe paginated slice
  List<InboxItem> get paginatedItems {
    final items = filteredItems;
    if (items.isEmpty) return [];

    // ensure current page within bounds
    final pages = totalPages;
    if (_currentPage < 1) _currentPage = 1;
    if (_currentPage > pages) _currentPage = pages;

    final start = (_currentPage - 1) * _rowsPerPage;
    final end = math.min(start + _rowsPerPage, items.length);
    if (start >= items.length) return [];
    return items.sublist(start, end);
  }

  // actions
  void setFilter(String filter) {
    _selectedFilter = filter;
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

  // optional: update an item status (e.g., mark Reviewed)
  void updateStatus(InboxItem item, String newStatus) {
    final idx = _allItems.indexOf(item);
    if (idx != -1) {
      _allItems[idx].status = newStatus;
      notifyListeners();
    }
  }

  // optional: expose total count
  int get totalItemsCount => filteredItems.length;
}
