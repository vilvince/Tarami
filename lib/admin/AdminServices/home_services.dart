// lib/AdminServices/admin_dashboard_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/home/data/home_model.dart'; // Adjust path as needed

class AdminDashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This function now contains the logic from your VM's _loadStats
  Future<HomeStats> getDashboardStats() async {
    final reviewedSnap = await _firestore
        .collection('word_submissions')
        .where('status', whereIn: ['approved', 'denied', 'flagged'])
        .get();

    int approved = 0, denied = 0, flagged = 0;
    for (final doc in reviewedSnap.docs) {
      final status = (doc.data()['status'] ?? '').toLowerCase();
      if (status == 'approved') approved++;
      if (status == 'denied') denied++;
      if (status == 'flagged') flagged++;
    }
    return HomeStats(
      approved: approved,
      denied: denied,
      read: reviewedSnap.docs.length,
      flagged: flagged,
    );
  }

  // This function contains the logic from your VM's _loadCommonWords
  Future<List<CommonWord>> getCommonWords() async {
    final historySnap = await _firestore.collectionGroup('recent_words').get();
    final Map<String, int> counts = {};

    for (final doc in historySnap.docs) {
      final w = (doc.data()['word'] ?? '').toString().trim().toLowerCase();
      if (w.isNotEmpty) counts[w] = (counts[w] ?? 0) + 1;
    }

    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(6).map((e) => CommonWord(word: e.key, count: e.value)).toList();
  }

// ... You would do the same for getTopContributors ...
  Future<List<TopContributor>> getTopContributors() async {
    final submissionsSnap = await _firestore.collection('word_submissions').get();
    final Map<String, int> counts = {};

    for (final doc in submissionsSnap.docs) {
      final email = (doc.data()['submitted_by_email'] ?? '').toString();
      if (email.isNotEmpty) {
        counts[email] = (counts[email] ?? 0) + 1;
      }
    }

    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(6).map((e) => TopContributor(name: e.key, words: e.value)).toList();
  }


  // In lib/AdminServices/admin_dashboard_service.dart

// ... (keep your existing methods)

  // ✅ ADD THIS NEW METHOD
  /// Fetches submissions from the last 7 days and groups them by day.
  Future<Map<DateTime, int>> getContributionsOverLastWeek() async {
    // Calculate the date 7 days ago from now.
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Query submissions within the last 7 days.
    final submissionsSnap = await _firestore
        .collection('word_submissions')
        .where('date_submitted', isGreaterThanOrEqualTo: sevenDaysAgo)
        .get();

    // Group the submissions by day.
    final Map<DateTime, int> dailyCounts = {};

    for (final doc in submissionsSnap.docs) {
      final timestamp = doc.data()['date_submitted'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        // Use a "normalized" date (without time) as the map key.
        final day = DateTime(date.year, date.month, date.day);
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }
    }
    return dailyCounts;
  }
}