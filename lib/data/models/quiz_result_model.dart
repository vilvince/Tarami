import 'package:tarami_application/data/models/user_status_model.dart';

class QuizResult {
  final int score;
  final int totalQuestions;
  final int currentStreak;
  final String badgeLevel;
  final bool isPerfectScore;
  final String difficulty; // Add difficulty field

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.currentStreak,
    required this.badgeLevel,
    required this.isPerfectScore,
    this.difficulty = 'easy', // Default to easy
  });

  double get percentage => (score / totalQuestions) * 100;

  // Create QuizResult from game data
  factory QuizResult.fromGameData({
    required int score,
    required int totalQuestions,
    required UserStats userStats,
    required String difficulty,
  }) {
    bool isPerfectScore = score == totalQuestions;

    return QuizResult(
      score: score,
      totalQuestions: totalQuestions,
      currentStreak: userStats.currentStreak,
      badgeLevel: userStats.badgeLevel,
      isPerfectScore: isPerfectScore,
      difficulty: difficulty,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'total_questions': totalQuestions,
      'current_streak': currentStreak,
      'badge_level': badgeLevel,
      'is_perfect_score': isPerfectScore,
      'difficulty': difficulty,
      'percentage': percentage,
    };
  }
}