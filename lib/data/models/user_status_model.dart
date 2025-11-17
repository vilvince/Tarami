import 'package:cloud_firestore/cloud_firestore.dart';

enum DifficultyLevel { easy, medium, hard }

class DifficultyStats {
  int games;
  int perfect;

  DifficultyStats({this.games = 0, this.perfect = 0});

  factory DifficultyStats.fromMap(Map<String, dynamic> map) {
    return DifficultyStats(
      games: map['games'] ?? 0,
      perfect: map['perfect'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'games': games, 'perfect': perfect};
  }
}

class UserStats {
  int currentStreak;
  String badgeLevel;
  int totalGames;
  DateTime lastPlayed;
  Map<String, DifficultyStats> difficultyStats;

  UserStats({
    this.currentStreak = 0,
    this.badgeLevel = "Learner",
    this.totalGames = 0,
    DateTime? lastPlayed,
    Map<String, DifficultyStats>? difficultyStats,
  })  : lastPlayed = lastPlayed ?? DateTime.now(),
        difficultyStats = difficultyStats ?? {
          'easy': DifficultyStats(),
          'medium': DifficultyStats(),
          'hard': DifficultyStats(),
        };

  factory UserStats.initial() {
    return UserStats();
  }

  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    Map<String, DifficultyStats> diffStats = {};
    if (data['difficulty_stats'] != null) {
      Map<String, dynamic> statsMap = Map<String, dynamic>.from(data['difficulty_stats']);
      statsMap.forEach((key, value) {
        diffStats[key] = DifficultyStats.fromMap(Map<String, dynamic>.from(value));
      });
    }
    ['easy', 'medium', 'hard'].forEach((level) {
      if (!diffStats.containsKey(level)) {
        diffStats[level] = DifficultyStats();
      }
    });

    return UserStats(
      currentStreak: data['current_streak'] ?? 0,
      badgeLevel: data['badge_level'] ?? "Learner",
      totalGames: data['total_games'] ?? 0,
      lastPlayed: data['last_played']?.toDate() ?? DateTime.now(),
      difficultyStats: diffStats,
    );
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> diffStatsMap = {};
    difficultyStats.forEach((key, value) {
      diffStatsMap[key] = value.toMap();
    });

    return {
      'current_streak': currentStreak,
      'badge_level': badgeLevel,
      'total_games': totalGames,
      'last_played': Timestamp.fromDate(lastPlayed),
      'difficulty_stats': diffStatsMap,
    };
  }

  /// Update stats after a game
  void updateAfterGame(int score, int totalQuestions, DifficultyLevel difficulty, bool isPerfectScore) {
    String difficultyStr = difficulty.toString().split('.').last;

    totalGames++;

    if (difficultyStats.containsKey(difficultyStr)) {
      difficultyStats[difficultyStr]!.games++;
      if (isPerfectScore) {
        difficultyStats[difficultyStr]!.perfect++;
      }
    }

    // ✅ YOUR NEW STREAK LOGIC:
    // Only increases on a perfect score, never decreases.
    if (isPerfectScore) {
      currentStreak++;
    }

    // Update badge level based on the new streak
    _updateBadgeLevel();

    lastPlayed = DateTime.now();
  }

  /// ✅ FIX: Update badge level logic based on currentStreak
  void _updateBadgeLevel() {
    if (currentStreak >= 21) {
      badgeLevel = "Speaker";
    } else if (currentStreak >= 11) {
      badgeLevel = "Moderate";
    } else {
      badgeLevel = "Learner";
    }
  }

  /// ✅ FIX: Get current difficulty based on currentStreak
  DifficultyLevel getCurrentDifficulty() {
    if (currentStreak >= 21) {
      return DifficultyLevel.hard;
    } else if (currentStreak >= 11) {
      return DifficultyLevel.medium;
    } else {
      return DifficultyLevel.easy;
    }
  }

  /// ✅ FIX: Get streak needed for next difficulty
  int getStreakForNextDifficulty() {
    if (currentStreak >= 21) {
      return 0; // Already at highest
    } else if (currentStreak >= 11) {
      return 21 - currentStreak; // Streaks needed to reach 21
    } else {
      return 11 - currentStreak; // Streaks needed to reach 11
    }
  }

  // --- Other helper methods ---

  int getTotalPerfectGames() {
    return difficultyStats.values
        .map((stats) => stats.perfect)
        .fold(0, (sum, perfect) => sum + perfect);
  }

  double getSuccessRate(String difficulty) {
    if (!difficultyStats.containsKey(difficulty)) return 0.0;
    final stats = difficultyStats[difficulty]!;
    if (stats.games == 0) return 0.0;
    return (stats.perfect / stats.games) * 100;
  }
}