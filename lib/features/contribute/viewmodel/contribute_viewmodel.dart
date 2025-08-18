import 'package:flutter/material.dart';

class ContributeViewModel extends ChangeNotifier {
  // Dropdown data
  final List<String> dialects = [
    'Central Bikol',
    'West Miraya',
    'East Miraya',
    'Libon Bikol',
  ];

  final List<String> partsOfSpeech = [
    'Noun', 'Verb', 'Adjective', 'Adverb', 'Pronoun', 'Conjunction', 'Preposition', 'Interjection'
  ];

  // Form state
  String? selectedDialect;
  String? selectedPartOfSpeech;

  final TextEditingController wordController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController phoneticController = TextEditingController();
  final TextEditingController tagalogTranslationController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final TextEditingController etymologyController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();
  final TextEditingController synonymsController = TextEditingController();

  bool showValidationErrors = false;
  int submissionCount = 0;
  final int maxSubmissionsPerDay = 5;

  // Dropdown selection
  void selectDialect(String? value) {
    selectedDialect = value;
    notifyListeners();
  }

  void selectPartOfSpeech(String? value) {
    selectedPartOfSpeech = value;
    notifyListeners();
  }

  // Form validation
  bool validateForm() {
    showValidationErrors = true;
    notifyListeners();
    return selectedDialect != null &&
        selectedPartOfSpeech != null &&
        wordController.text.isNotEmpty &&
        translationController.text.isNotEmpty &&
        phoneticController.text.isNotEmpty &&
        tagalogTranslationController.text.isNotEmpty &&
        definitionController.text.isNotEmpty &&
        exampleController.text.isNotEmpty;
  }

  bool canSubmit() => submissionCount < maxSubmissionsPerDay;

  void submitForm() {
    submissionCount++;
    clearForm();
  }

  void clearForm() {
    selectedDialect = null;
    selectedPartOfSpeech = null;
    wordController.clear();
    translationController.clear();
    phoneticController.clear();
    tagalogTranslationController.clear();
    definitionController.clear();
    etymologyController.clear();
    exampleController.clear();
    synonymsController.clear();
    showValidationErrors = false;
    notifyListeners();
  }
}
