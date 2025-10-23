import 'package:flutter/material.dart';
import '../data/contribute_model.dart';

class AdminContributeViewModel extends ChangeNotifier {
  // Controllers for form inputs
  final TextEditingController wordController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController phoneticController = TextEditingController();
  final TextEditingController tagalogTranslationController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();
  final TextEditingController exampleSentenceInDialectController = TextEditingController();
  final TextEditingController exampleSentenceInEnglishController = TextEditingController();
  final TextEditingController synonymsController = TextEditingController();

  // Dropdown selected values
  String? selectedDialect;
  String? selectedPartOfSpeech;

  // Validation flag
  bool showValidationErrors = false;


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

  //form validation
  bool validateForm(){
    showValidationErrors = true;
    notifyListeners();

    if (selectedDialect == null ||
        selectedPartOfSpeech == null ||
        wordController.text.isEmpty ||
        translationController.text.isEmpty ||
        phoneticController.text.isEmpty ||
        tagalogTranslationController.text.isEmpty ||
        definitionController.text.isEmpty ||
        exampleSentenceInDialectController.text.isEmpty ||
        exampleSentenceInEnglishController.text.isEmpty){
      return false;
    } return true;
  }

  //Select handlers
  void selectDialect(String? dialect){
    selectedDialect = dialect;
    notifyListeners();
  }

  void selectPartOfSpeech(String? partOfSpeech) {
    selectedPartOfSpeech = partOfSpeech;
    notifyListeners();
  }




  // Submit new contribution
  void submitContribution() {
    final newContribution = ContributeModel(
      dialect: selectedDialect!,
      word: wordController.text.trim(),
      translation: translationController.text.trim(),
      phonetic: phoneticController.text.trim(),
      tagalogTranslation: tagalogTranslationController.text.trim(),
      partOfSpeech: selectedPartOfSpeech!,
      definition: definitionController.text.trim(),
      exampleSentenceInDialect: exampleSentenceInDialectController.text.trim(),
      exampleSentenceInEnglish: exampleSentenceInEnglishController.text.trim(),
      synonyms: synonymsController.text.trim().isEmpty ? null: synonymsController.text.trim(),
    );

    contributions.add(newContribution);
    clearForm();
    notifyListeners();
  }

  // Reset form fields
  void clearForm() {
    selectedDialect = null;
    selectedPartOfSpeech = null;
    wordController.clear();
    translationController.clear();
    phoneticController.clear();
    tagalogTranslationController.clear();
    definitionController.clear();
    exampleSentenceInDialectController.clear();
    exampleSentenceInEnglishController.clear();
    synonymsController.clear();
  }
}