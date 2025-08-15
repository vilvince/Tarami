import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/question_model.dart';
import 'package:tarami_application/data/models/quiz_result_model.dart';
import 'package:tarami_application/data/models/user_status_model.dart';
import 'package:tarami_application/core/services/quiz_service.dart';

enum QuizState { initial, inProgress, completed }
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

  // User stats (in real app, load from database)
  UserStats _userStats = UserStats();

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

  void startQuiz() {
    _quizState = QuizState.inProgress;
    _questions = QuizService.getSampleQuestions();
    _currentQuestionIndex = 0;
    _userAnswers = List.filled(_questions.length, null);
    _answerStates = List.filled(4, AnswerState.none);
    _selectedAnswer = null;
    _hasAnswered = false;
    notifyListeners();
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

  void _completeQuiz() {
    _quizState = QuizState.completed;
    notifyListeners();
  }

  QuizResult getQuizResult() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctAnswerIndex) {
        score++;
      }
    }

    bool isPerfectScore = score == _questions.length;

    // Update user stats
    _userStats.updateStats(isPerfectScore);

    return QuizResult(
      score: score,
      totalQuestions: _questions.length,
      currentStreak: _userStats.streak,
      badgeLevel: _userStats.badgeLevel,
      isPerfectScore: isPerfectScore,
    );
  }

  void resetQuiz() {
    _quizState = QuizState.initial;
    _currentQuestionIndex = 0;
    _selectedAnswer = null;
    _hasAnswered = false;
    _userAnswers.clear();
    _answerStates = List.filled(4, AnswerState.none);
    notifyListeners();
  }
}

