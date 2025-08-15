class UserStats {
  int streak;
  String badgeLevel;

  UserStats({
    this.streak = 0,
    this.badgeLevel = "Learner",
  });

  void updateStats(bool isPerfectScore) {
    if (isPerfectScore) {
      streak++;
      // Update badge based on streak
      if (streak >= 30) {
        badgeLevel = "Learner";
      } else if (streak >= 20) {
        badgeLevel = "Speaker";
      } else if (streak >= 10) {
        badgeLevel = "Moderate";
      }
    }
    // Note: streak doesn't reset on imperfect score, just doesn't increase
  }
}