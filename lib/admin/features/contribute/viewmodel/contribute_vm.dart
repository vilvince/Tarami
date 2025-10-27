import 'package:flutter/material.dart';
import '../data/contribute_model.dart';
import '../../../AdminServices/admin_contribute_service.dart';
class AdminContributeViewModel extends ChangeNotifier {
  final AdminContributeService _service = AdminContributeService();

// Form state
  final TextEditingController wordController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController phoneticController = TextEditingController();
  final TextEditingController tagalogTranslationController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final TextEditingController exampleSentenceInDialectController = TextEditingController();
  final TextEditingController exampleSentenceInEnglishController = TextEditingController();
  final TextEditingController synonymsController = TextEditingController();
  String? selectedDialect;
  String? selectedPartOfSpeech;

  // UI state
  bool showValidationErrors = false;
  bool _isSubmitting = false;
  String? _error;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

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


  //Select handlers
  void selectDialect(String? dialect){
    selectedDialect = dialect;
    notifyListeners();
  }

  void selectPartOfSpeech(String? partOfSpeech) {
    selectedPartOfSpeech = partOfSpeech;
    notifyListeners();
  }

  bool validateForm() {
    showValidationErrors = true;
    notifyListeners();

    return selectedDialect != null &&
        selectedPartOfSpeech != null &&
        wordController.text.isNotEmpty &&
        translationController.text.isNotEmpty &&
        definitionController.text.isNotEmpty;
  }

  Future<void> submitContribution() async {
    if (!validateForm()) {
      throw Exception("Please fill all required fields.");
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final newContribution = ContributeModel(
        dialect: selectedDialect!,
        word: wordController.text,
        translation: translationController.text,
        phonetic: phoneticController.text,
        tagalogTranslation: tagalogTranslationController.text,
        partOfSpeech: selectedPartOfSpeech!,
        definition: definitionController.text,
        exampleSentenceInDialect: exampleSentenceInDialectController.text,
        exampleSentenceInEnglish: exampleSentenceInEnglishController.text,
        synonyms: synonymsController.text,
      );

      await _service.submitDirectContribution(newContribution);
      clearForm(); // Clear the form on successful submission
    } catch (e) {
      _error = e.toString();
      // Rethrow the error so the UI can catch it and display a message
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

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
    showValidationErrors = false;
    _error = null;
    notifyListeners(); // Update UI after clearing
  }

  @override
  void dispose() {
    wordController.dispose();
    translationController.dispose();
    phoneticController.dispose();
    tagalogTranslationController.dispose();
    definitionController.dispose();
    exampleSentenceInDialectController.dispose();
    exampleSentenceInEnglishController.dispose();
    synonymsController.dispose();
    super.dispose();
  }
}