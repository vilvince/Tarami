class RecentItem {
  final String word;
  // You could add other properties here in the future, e.g.:
  // final DateTime dateAdded;

  RecentItem({required this.word});

  // Optional: If you need to compare items or use them in sets/maps
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RecentItem && runtimeType == other.runtimeType && word == other.word;

  @override
  int get hashCode => word.hashCode;
}