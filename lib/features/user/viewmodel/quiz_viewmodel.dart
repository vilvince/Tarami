import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/question_model.dart';
import 'package:tarami_application/data/models/quiz_result_model.dart';
import 'package:tarami_application/data/models/user_status_model.dart';
import 'package:tarami_application/core/services/game_service.dart';

enum QuizState { initial, loading, inProgress, completed, error }
enum AnswerState { none, correct, incorrect }

class QuizViewModel extends ChangeNotifier {
  // Quiz state
  QuizState _quizState = QuizState.initial;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  List<AnswerState> _answerStates = [];
  int? _selectedAnswer;
  bool _hasAnswered = false;
  String? _errorMessage;

  // User stats and difficulty
  UserStats _userStats = UserStats.initial();
  DifficultyLevel _currentDifficulty = DifficultyLevel.easy;

  // Getters
  QuizState get quizState => _quizState;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  int? get selectedAnswer => _selectedAnswer;
  bool get hasAnswered => _hasAnswered;
  List<AnswerState> get answerStates => _answerStates;
  int get totalQuestions => _questions.length;
  int get questionNumber => _currentQuestionIndex + 1;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  String? get errorMessage => _errorMessage;
  UserStats get userStats => _userStats;
  DifficultyLevel get currentDifficulty => _currentDifficulty;
  String get difficultyDisplayName => _getDifficultyDisplayName(_currentDifficulty);

  // Get difficulty display name
  String _getDifficultyDisplayName(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
    }
  }

  // Initialize user stats and difficulty
  Future<void> initializeGame() async {
    try {
      _quizState = QuizState.loading;
      notifyListeners();

      // Load user stats and determine current difficulty
      _userStats = await FirebaseGameService.getUserStats();
      _currentDifficulty = await FirebaseGameService.getCurrentDifficulty();

      _quizState = QuizState.initial;
      notifyListeners();
    } catch (e) {
      _quizState = QuizState.error;
      _errorMessage = 'Failed to initialize game: $e';
      notifyListeners();
    }
  }

  // Start quiz with Firebase questions
  Future<void> startQuiz() async {
    try {
      _quizState = QuizState.loading;
      notifyListeners();

      // Get questions from Firebase based on current difficulty
      _questions = await FirebaseGameService.getQuestionsByDifficulty(_currentDifficulty);

      if (_questions.isEmpty) {
        throw Exception('No questions available for selected difficulty');
      }

      // Initialize quiz state
      _quizState = QuizState.inProgress;
      _currentQuestionIndex = 0;
      _userAnswers = List.filled(_questions.length, null);
      _answerStates = List.filled(4, AnswerState.none);
      _selectedAnswer = null;
      _hasAnswered = false;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _quizState = QuizState.error;
      _errorMessage = 'Failed to load questions: $e';
      notifyListeners();
    }
  }

  void selectAnswer(int answerIndex) {
    if (_hasAnswered) return;

    _selectedAnswer = answerIndex;
    _hasAnswered = true;
    _userAnswers[_currentQuestionIndex] = answerIndex;

    // Update answer states for visual feedback
    _answerStates = List.filled(4, AnswerState.none);

    final correctIndex = currentQuestion!.correctAnswerIndex;

    // Mark correct answer as green
    _answerStates[correctIndex] = AnswerState.correct;

    // Mark selected wrong answer as red (if different from correct)
    if (answerIndex != correctIndex) {
      _answerStates[answerIndex] = AnswerState.incorrect;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _hasAnswered = false;
      _answerStates = List.filled(4, AnswerState.none);
      notifyListeners();
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    try {
      _quizState = QuizState.loading;
      notifyListeners();

      // Calculate score
      int score = _calculateScore();

      // Update user stats in Firebase
      await FirebaseGameService.updateUserStats(score, _questions.length, _currentDifficulty);

      // Reload updated user stats
      _userStats = await FirebaseGameService.getUserStats();

      // Create quiz result
      final result = QuizResult.fromGameData(
        score: score,
        totalQuestions: _questions.length,
        userStats: _userStats,
        difficulty: FirebaseGameService.difficultyToString(_currentDifficulty),
      );

      // Save game session
      await FirebaseGameService.saveGameSession(result, _currentDifficulty);

      _quizState = QuizState.completed;
      notifyListeners();
    } catch (e) {
      _quizState = QuizState.error;
      _errorMessage = 'Failed to save quiz results: $e';
      notifyListeners();
    }
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctAnswerIndex) {
        score++;
      }
    }
    return score;
  }

  QuizResult getQuizResult() {
    int score = _calculateScore();
    bool isPerfectScore = score == _questions.length;

    return QuizResult.fromGameData(
      score: score,
      totalQuestions: _questions.length,
      userStats: _userStats,
      difficulty: FirebaseGameService.difficultyToString(_currentDifficulty),
    );
  }

  Future<void> resetQuiz() async {
    _quizState = QuizState.initial;
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _hasAnswered = false;
    _userAnswers.clear();
    _answerStates = List.filled(4, AnswerState.none);
    _errorMessage = null;

    // Reload user stats to get updated difficulty
    try {
      _userStats = await FirebaseGameService.getUserStats();
      _currentDifficulty = await FirebaseGameService.getCurrentDifficulty();
    } catch (e) {
      print('Error reloading user stats: $e');
    }

    notifyListeners();
  }

  // Get user's game history
  Future<List<Map<String, dynamic>>> getGameHistory() async {
    try {
      return await FirebaseGameService.getGameHistory();
    } catch (e) {
      print('Error getting game history: $e');
      return [];
    }
  }

  // Check if difficulty will change after next perfect score
  bool willDifficultyIncrease() {
    if (_currentDifficulty == DifficultyLevel.hard) return false;

    int streaksNeeded = _userStats.getStreakForNextDifficulty();
    return streaksNeeded == 1; // Will level up with next perfect score
  }

  // Get progress toward next difficulty
  double getDifficultyProgress() {
    switch (_currentDifficulty) {
      case DifficultyLevel.easy:
        return (_userStats.currentStreak / 10).clamp(0.0, 1.0);
      case DifficultyLevel.medium:
        return ((_userStats.currentStreak - 10) / 10).clamp(0.0, 1.0);
      case DifficultyLevel.hard:
        return 1.0; // Max level reached
    }
  }

  // Get next difficulty name
  String? getNextDifficultyName() {
    switch (_currentDifficulty) {
      case DifficultyLevel.easy:
        return 'Medium';
      case DifficultyLevel.medium:
        return 'Hard';
      case DifficultyLevel.hard:
        return null; // Already at max
    }
  }

  // Retry quiz if error occurred
  Future<void> retryQuiz() async {
    if (_quizState == QuizState.error) {
      await startQuiz();
    }
  }
}