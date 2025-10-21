class HomeStats {
  final int approved;
  final int denied;
  final int read;
  final int flagged;

  HomeStats({
    required this.approved,
    required this.denied,
    required this.read,
    required this.flagged,
  });
}

class TopContributor {
  final String name;
  final int words;

  TopContributor({required this.name, required this.words});
}

class CommonWord {
  final String word;
  final int count;

  CommonWord({required this.word, required this.count});
}
