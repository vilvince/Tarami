// lib/features/home/viewmodel/home_vm.dart
import 'package:flutter/foundation.dart';
import '../../../AdminServices/home_services.dart'; // Import the new service
import '../data/home_model.dart';

class HomeVM extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService(); // Use the new service

  // ... (state variables are the same)
  bool isLoading = true;
  String? errorMessage;
  HomeStats stats = HomeStats(approved: 0, denied: 0, read: 0, flagged: 0);
  List<CommonWord> commonWords = [];
  List<TopContributor> contributors = [];
  Map<DateTime, int> weeklyContributions = {};

  // ... (other methods are the same)

  HomeVM() {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      // Now the VM calls the service instead of doing the query itself
      final results = await Future.wait([
        _service.getDashboardStats(),
        _service.getCommonWords(),
        _service.getTopContributors(),
        _service.getContributionsOverLastWeek()
      ]);

      // Assign results to state
      stats = results[0] as HomeStats;
      commonWords = results[1] as List<CommonWord>;
      contributors = results[2] as List<TopContributor>;
      weeklyContributions = results[3] as Map<DateTime, int>;

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load dashboard data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}