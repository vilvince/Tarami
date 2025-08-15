class QuizResult {
  final int score;
  final int totalQuestions;
  final int currentStreak;
  final String badgeLevel;
  final bool isPerfectScore;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.currentStreak,
    required this.badgeLevel,
    required this.isPerfectScore,
  });

  double get percentage => (score / totalQuestions) * 100;
}