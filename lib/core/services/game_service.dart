import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/data/models/question_model.dart';
import 'package:tarami_application/data/models/quiz_result_model.dart';
import 'package:tarami_application/data/models/user_status_model.dart';
import 'package:tarami_application/core/services/quiz_service.dart'; // Import your existing quiz service

class FirebaseGameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // Convert difficulty enum to string
  static String difficultyToString(DifficultyLevel difficulty) {
    return difficulty
        .toString()
        .split('.')
        .last;
  }

  // Convert string to difficulty enum
  static DifficultyLevel stringToDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'medium':
        return DifficultyLevel.medium;
      case 'hard':
        return DifficultyLevel.hard;
      default:
        return DifficultyLevel.easy;
    }
  }

  // Get user's current game stats
  static Future<UserStats> getUserStats() async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('user_game_stats')
          .doc('stats')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return UserStats.fromFirestore(data);
      } else {
        // Create initial stats for new user
        final initialStats = UserStats.initial();
        await _createInitialUserStats(initialStats);
        return initialStats;
      }
    } catch (e) {
      print('Error getting user stats: $e');
      return UserStats.initial();
    }
  }

  // Create initial user stats
  static Future<void> _createInitialUserStats(UserStats stats) async {
    if (currentUserId == null) return;

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('user_game_stats')
        .doc('stats')
        .set(stats.toFirestore());
  }

  // Get questions based on difficulty
  static Future<List<Question>> getQuestionsByDifficulty(
      DifficultyLevel difficulty) async {
    try {
      final querySnapshot = await _firestore
          .collection('vocabulary_game')
          .where('difficulty', isEqualTo: difficultyToString(difficulty))
          .limit(20) // Get more than needed for randomization
          .get();

      List<Question> questions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Question.fromFirestore(doc.id, data);
      }).toList();

      // Shuffle and return only 10 questions
      questions.shuffle();
      return questions.take(10).toList();
    } catch (e) {
      print('Error fetching questions: $e');
      // Fallback to existing quiz service if Firestore fails
      return _getFallbackQuestions(difficulty);
    }
  }

  // Fallback to existing quiz service questions
  static List<Question> _getFallbackQuestions(DifficultyLevel difficulty) {
    // Use your existing QuizService questions as fallback
    List<Question> existingQuestions = QuizService.getSampleQuestions();

    // Since existing questions don't have difficulty levels,
    // we'll add them dynamically based on complexity or just use all for any difficulty
    List<Question> questionsWithDifficulty = existingQuestions.map((q) =>
        Question(
          id: q.id,
          question: q.question,
          options: q.options,
          correctAnswerIndex: q.correctAnswerIndex,
          difficulty: difficultyToString(
              difficulty), // Assign current difficulty
        )).toList();

    questionsWithDifficulty.shuffle();
    return questionsWithDifficulty.take(10).toList();
  }

  // Update user stats after quiz completion
  static Future<void> updateUserStats(int score, int totalQuestions,
      DifficultyLevel difficulty) async {
    if (currentUserId == null) return;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('user_game_stats')
          .doc('stats');

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        UserStats currentStats;
        if (doc.exists) {
          currentStats = UserStats.fromFirestore(doc.data()!);
        } else {
          currentStats = UserStats.initial();
        }

        // Update stats based on game result
        bool isPerfectScore = score == totalQuestions;
        currentStats.updateAfterGame(
            score, totalQuestions, difficulty, isPerfectScore);

        // Write updated stats to Firestore
        transaction.set(docRef, currentStats.toFirestore());
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Get user's current difficulty level
  static Future<DifficultyLevel> getCurrentDifficulty() async {
    final stats = await getUserStats();
    return stats.getCurrentDifficulty();
  }

  // Save individual game session
  static Future<void> saveGameSession(QuizResult result,
      DifficultyLevel difficulty) async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('game_sessions')
          .add({
        'score': result.score,
        'total_questions': result.totalQuestions,
        'difficulty': difficultyToString(difficulty),
        'is_perfect': result.isPerfectScore,
        'percentage': result.percentage,
        'timestamp': FieldValue.serverTimestamp(),
        'badge_at_time': result.badgeLevel,
        'streak_at_time': result.currentStreak,
      });
    } catch (e) {
      print('Error saving game session: $e');
    }
  }

  // Get user's game history
  static Future<List<Map<String, dynamic>>> getGameHistory(
      {int limit = 10}) async {
    if (currentUserId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('game_sessions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting game history: $e');
      return [];
    }
  }

  // Get leaderboard data (optional feature)
  static Future<List<Map<String, dynamic>>> getLeaderboard(
      {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('user_game_stats.current_streak', isGreaterThan: 0)
          .orderBy('user_game_stats.current_streak', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
}