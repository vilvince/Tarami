import 'package:flutter/material.dart';
import '../data/word_model.dart';

class WordVM extends ChangeNotifier {
  String selectedDialect = "Central Bikol";

  final Map<String, List<WordModel>> _words = {
    "Central Bikol": [
      WordModel(word: "Aback", dialect: "Central Bikol"),
      WordModel(word: "Abandon", dialect: "Central Bikol"),
      WordModel(word: "Abase", dialect: "Central Bikol"),
    ],
    "West Miraya": [
      WordModel(word: "Abate", dialect: "West Miraya"),
      WordModel(word: "Abbreviate", dialect: "West Miraya"),
    ],
    "East Miraya": [
      WordModel(word: "Abbreviation", dialect: "East Miraya"),
      WordModel(word: "Abdicate", dialect: "East Miraya"),
    ],
    "Libon Bikol": [
      WordModel(word: "Abdomen", dialect: "Libon Bikol"),
      WordModel(word: "Abduct", dialect: "Libon Bikol"),
    ],
  };

  // Selection mode & selected words
  bool selectionMode = false;
  List<String> selectedWords = [];

  List<WordModel> get words => _words[selectedDialect] ?? [];

  void setDialect(String dialect) {
    selectedDialect = dialect;
    cancelSelectionMode(); // reset selection
    notifyListeners();
  }

  void toggleSelectionMode() {
    selectionMode = !selectionMode;
    if (!selectionMode) selectedWords.clear();
    notifyListeners();
  }

  void cancelSelectionMode() {
    selectionMode = false;
    selectedWords.clear();
    notifyListeners();
  }

  void toggleWordSelection(String word) {
    if (selectedWords.contains(word)) {
      selectedWords.remove(word);
    } else {
      selectedWords.add(word);
    }
    notifyListeners();
  }

  void deleteSelectedWords() {
    _words[selectedDialect]
        ?.removeWhere((wordModel) => selectedWords.contains(wordModel.word));
    cancelSelectionMode();
  }
}
