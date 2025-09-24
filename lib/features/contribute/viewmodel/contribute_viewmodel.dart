import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/contribute_model.dart';
import 'package:tarami_application/core/services/contribution_service.dart';

class ContributeViewModel extends ChangeNotifier {
  final ContributionService _contributionService = ContributionService();

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
  final TextEditingController exampleSentenceInDialectController = TextEditingController();
  final TextEditingController exampleSentenceInEnglishController = TextEditingController();
  final TextEditingController synonymsController = TextEditingController();

  bool showValidationErrors = false;
  int submissionCount = 0;
  final int maxSubmissionsPerDay = 5;

  // Loading and error states
  bool isSubmitting = false;
  bool isLoadingCount = true;
  String? errorMessage;

  ContributeViewModel() {
    _loadTodaySubmissionCount();
  }

  // Load today's submission count
  Future<void> _loadTodaySubmissionCount() async {
    isLoadingCount = true;
    notifyListeners();

    try {
      submissionCount = await _contributionService.getTodaySubmissionCount();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load submission count: $e';
      // Set to 0 if there's an error so user can still try to submit
      submissionCount = 0;
    }

    isLoadingCount = false;
    notifyListeners();
  }

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
        exampleSentenceInDialectController.text.isNotEmpty &&
        exampleSentenceInEnglishController.text.isNotEmpty;
  }

  bool canSubmit() => submissionCount < maxSubmissionsPerDay;

  int get remainingSubmissions => maxSubmissionsPerDay - submissionCount;

  // Submit form to Firebase
  Future<bool> submitForm() async {
    if (!validateForm()) return false;

    // Double-check submission limit
    final canSubmitNow = await _contributionService.checkDailySubmissionLimit();
    if (!canSubmitNow) {
      errorMessage = 'You have reached your daily submission limit of $maxSubmissionsPerDay words.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Create contribution model
      final contribution = ContributeModel(
        dialect: selectedDialect!,
        word: wordController.text.trim(),
        translation: translationController.text.trim(),
        phonetic: phoneticController.text.trim(),
        tagalogTranslation: tagalogTranslationController.text.trim(),
        partOfSpeech: selectedPartOfSpeech!,
        definition: definitionController.text.trim(),
        exampleSentenceInDialect: exampleSentenceInDialectController.text.trim(),
        exampleSentenceInEnglish: exampleSentenceInEnglishController.text.trim(),
        synonyms: synonymsController.text.trim().isEmpty ? null : synonymsController.text.trim(),
      );

      // Submit to Firebase
      final success = await _contributionService.submitContribution(contribution);

      if (success) {
        // Update local count and clear form
        submissionCount++;
        clearForm();
        return true;
      } else {
        errorMessage = 'Failed to submit word. Please try again.';
        return false;
      }

    } catch (e) {
      errorMessage = 'Error submitting word: $e';
      return false;
    } finally {
      isSubmitting = false;
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
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
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