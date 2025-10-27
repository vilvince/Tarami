import 'package:flutter/material.dart';
import '../data/word_model.dart';
import '../../../AdminServices/admin_word_management_service.dart';

class WordVM extends ChangeNotifier {
  final WordManagementService _service = WordManagementService();

  //State
  List<WordModel> _allWords = [];
  bool _isLoading = true;
  String? _error;
  String selectedDialect = "Central Bikol";

  // Selection mode & selected words
  bool selectionMode = false;
  Set<String> selectedUniqueIds = {};

  //Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WordModel> get filteredWords => _allWords.where((w) => w.dialect == selectedDialect).toList();

  WordVM() {
    _loadWords();
  }

  Future<void> _loadWords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      _allWords = await _service.getAllDictionaryWords();
      _allWords.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
    }catch (e){
      _error = e.toString();
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Public method to reload (called from UI after dialog closes)
  Future<void> reloadWordsPublic() async {
    try {
      _allWords = await _service.getAllDictionaryWords();
      _allWords.sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void setDialect(String dialect) {
    selectedDialect = dialect;
    cancelSelectionMode();
    notifyListeners();
  }

  void toggleSelectionMode() {
    selectionMode = !selectionMode;
    if (!selectionMode) selectedUniqueIds.clear();
    notifyListeners();
  }

  void cancelSelectionMode() {
    selectionMode = false;
    selectedUniqueIds.clear();
    notifyListeners();
  }

  // 🔹 NEW: Silent cancel without notifyListeners
  void _cancelSelectionSilent() {
    selectionMode = false;
    selectedUniqueIds.clear();
    // DON'T call notifyListeners here
  }

  void toggleWordSelection(String wordId) {
    if (selectedUniqueIds.contains(wordId)) {
      selectedUniqueIds.remove(wordId);
    } else {
      selectedUniqueIds.add(wordId);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedWords() async {
    if (selectedUniqueIds.isEmpty) return;

    // Set a loading state for the UI to show a spinner.
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, List<String>> deletions = {};
      for (final uniqueId in selectedUniqueIds) {
        final wordModel = _allWords.firstWhere((w) => w.uniqueId == uniqueId);
        (deletions[wordModel.id] ??= []).add(wordModel.dialectKey);
      }

      // Call the corrected service method.
      await _service.deleteSelected(deletions);

      // On success, clear the selection and reload the entire word list from Firestore.
      cancelSelectionMode(); // This will clear selectedUniqueIds
      await _loadWords(); // This re-fetches and calls notifyListeners() automatically

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow the error so the UI can catch it
    }
  }
}