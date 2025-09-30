import 'package:cloud_firestore/cloud_firestore.dart';

enum DifficultyLevel { easy, medium, hard }

class DifficultyStats {
  int games;
  int perfect;

  DifficultyStats({
    this.games = 0,
    this.perfect = 0,
  });

  factory DifficultyStats.fromMap(Map<String, dynamic> map) {
    return DifficultyStats(
      games: map['games'] ?? 0,
      perfect: map['perfect'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'games': games,
      'perfect': perfect,
    };
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
  }) :
        lastPlayed = lastPlayed ?? DateTime.now(),
        difficultyStats = difficultyStats ?? {
          'easy': DifficultyStats(),
          'medium': DifficultyStats(),
          'hard': DifficultyStats(),
        };

  // Create initial stats for new users
  factory UserStats.initial() {
    return UserStats(
      currentStreak: 0,
      badgeLevel: "Learner",
      totalGames: 0,
      lastPlayed: DateTime.now(),
      difficultyStats: {
        'easy': DifficultyStats(),
        'medium': DifficultyStats(),
        'hard': DifficultyStats(),
      },
    );
  }

  // Create UserStats from Firestore document
  factory UserStats.fromFirestore(Map<String, dynamic> data) {
    Map<String, DifficultyStats> diffStats = {};

    if (data['difficulty_stats'] != null) {
      Map<String, dynamic> statsMap = Map<String, dynamic>.from(data['difficulty_stats']);
      statsMap.forEach((key, value) {
        diffStats[key] = DifficultyStats.fromMap(Map<String, dynamic>.from(value));
      });
    }

    // Ensure all difficulty levels are present
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

  // Convert UserStats to Firestore document
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

  // Update stats after a game
  void updateAfterGame(int score, int totalQuestions, DifficultyLevel difficulty, bool isPerfectScore) {
    String difficultyStr = difficulty.toString().split('.').last;

    // Update total games
    totalGames++;

    // Update difficulty-specific stats
    if (difficultyStats.containsKey(difficultyStr)) {
      difficultyStats[difficultyStr]!.games++;
      if (isPerfectScore) {
        difficultyStats[difficultyStr]!.perfect++;
      }
    }

    // Update streak
    if (isPerfectScore) {
      currentStreak++;
    } else {
      // Streak stays the same (doesn't reset)
    }

    // Update badge level based on total perfect games across all difficulties
    _updateBadgeLevel();

    // Update last played
    lastPlayed = DateTime.now();
  }

  // Update badge level logic
  void _updateBadgeLevel() {
    int totalPerfectGames = difficultyStats.values
        .map((stats) => stats.perfect)
        .fold(0, (sum, perfect) => sum + perfect);

    if (totalPerfectGames >= 30) {
      badgeLevel = "Speaker";
    } else if (totalPerfectGames >= 10) {
      badgeLevel = "Moderate";
    } else {
      badgeLevel = "Learner";
    }
  }

  // Get current difficulty based on streak
  DifficultyLevel getCurrentDifficulty() {
    if (currentStreak >= 20) {
      return DifficultyLevel.hard;
    } else if (currentStreak >= 10) {
      return DifficultyLevel.medium;
    } else {
      return DifficultyLevel.easy;
    }
  }

  // Get streak needed for next difficulty
  int getStreakForNextDifficulty() {
    DifficultyLevel currentDiff = getCurrentDifficulty();
    switch (currentDiff) {
      case DifficultyLevel.easy:
        return 10 - currentStreak;
      case DifficultyLevel.medium:
        return 20 - currentStreak;
      case DifficultyLevel.hard:
        return 0; // Already at highest
    }
  }

  // Get total perfect games
  int getTotalPerfectGames() {
    return difficultyStats.values
        .map((stats) => stats.perfect)
        .fold(0, (sum, perfect) => sum + perfect);
  }

  // Get success rate for a difficulty
  double getSuccessRate(String difficulty) {
    if (!difficultyStats.containsKey(difficulty)) return 0.0;
    final stats = difficultyStats[difficulty]!;
    if (stats.games == 0) return 0.0;
    return (stats.perfect / stats.games) * 100;
  }

  // Legacy methods for backward compatibility
  void updateStats(bool isPerfectScore) {
    if (isPerfectScore) {
      currentStreak++;
      _updateBadgeLevel();
    }
    lastPlayed = DateTime.now();
  }

  // Legacy getter for compatibility
  int get streak => currentStreak;
}