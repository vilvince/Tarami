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

  List<WordModel> get words => _words[selectedDialect] ?? [];

  void setDialect(String dialect) {
    selectedDialect = dialect;
    notifyListeners();
  }
}
