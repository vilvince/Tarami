import 'package:flutter/material.dart';
import '../data/contribute_model.dart';

class ContributeVM extends ChangeNotifier {
  // Controllers for form inputs
  final TextEditingController wordController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController pronunciationController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();

  // Dropdown selected values
  String? selectedDialect;
  String? selectedPartOfSpeech;

  // Static lists
  final List<String> dialects = [
    'Central Bikol',
    'West Miraya',
    'East Miraya',
    'Libon Bikol',
  ];

  final List<String> partsOfSpeech = [
    'Noun',
    'Verb',
    'Adjective',
    'Adverb',
    'Pronoun',
    'Preposition',
    'Conjunction',
    'Interjection',
  ];

  // Contributions list
  final List<ContributeModel> contributions = [];

  // Submit new contribution
  void submitContribution() {
    if (selectedDialect == null ||
        selectedPartOfSpeech == null ||
        wordController.text.isEmpty ||
        translationController.text.isEmpty ||
        pronunciationController.text.isEmpty ||
        meaningController.text.isEmpty ||
        sentenceController.text.isEmpty) {
      return; // Validation failed
    }

    final newContribution = ContributeModel(
      dialect: selectedDialect!,
      word: wordController.text,
      translation: translationController.text,
      pronunciation: pronunciationController.text,
      partOfSpeech: selectedPartOfSpeech!,
      meaning: meaningController.text,
      sentence: sentenceController.text,
    );

    contributions.add(newContribution);
    clearForm();
    notifyListeners();
  }

  // Reset form fields
  void clearForm() {
    wordController.clear();
    translationController.clear();
    pronunciationController.clear();
    meaningController.clear();
    sentenceController.clear();
    selectedDialect = null;
    selectedPartOfSpeech = null;
  }
}
