import 'package:flutter/material.dart';
import '../data/submission_model.dart';

class SubmissionVM extends ChangeNotifier {
  String selectedFilter = "Approved";
  int currentPage = 1;
  int rowsPerPage = 10;

  final List<SubmissionModel> _submissions = [
    SubmissionModel(
      email: "example@email.com",
      submittedWord: "Feet",
      dialect: "Central Bikol",
      translation: "Bitis",
      date: "03/25/2025",
      partOfSpeech: "Noun",
      status: "Approved",
      phonetic: "fēt",
      tagalog: "Paa",
      definition: "The lower extremity of the leg below the ankle.",
      example: "She hurt her foot while running.",
      synonyms: "foot, extremity",
    ),
    SubmissionModel(
      email: "user@email.com",
      submittedWord: "Head",
      dialect: "West Miraya",
      translation: "Ulo",
      date: "03/25/2025",
      partOfSpeech: "Noun",
      status: "Denied",
      phonetic: "hed",
      tagalog: "Ulo",
      definition: "The upper part of the human body.",
      example: "He nodded his head in agreement.",
      synonyms: "cranium, skull",
    ),
    SubmissionModel(
      email: "sample@email.com",
      submittedWord: "Hand",
      dialect: "Libon Bikol",
      translation: "Kamot",
      date: "03/25/2025",
      partOfSpeech: "Noun",
      status: "Flagged",
      phonetic: "hand",
      tagalog: "Kamay",
      definition: "The end part of a person's arm.",
      example: "She waved her hand.",
      synonyms: "palm, fist",
    ),
  ];

  List<SubmissionModel> get filteredItems {
    if (selectedFilter == "All") return _submissions;
    return _submissions.where((item) => item.status == selectedFilter).toList();
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
}
