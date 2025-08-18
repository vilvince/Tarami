class DictionaryEntry {
  final String word; // e.g. "Aback"
  final Map<String, String> translations; // e.g. { "Central Bikol": "Nakigkig" }
  final Map<String, String> sampleSentences; // e.g. { "Central Bikol": "Nag-abot si Juan..." }
  final List<String> synonyms; // e.g. ["Surprised", "Startled"]
  final List<String> antonyms; // e.g. ["Calm", "Unmoved"]
  final Map<String, String> etymologies; // e.g. { "Central Bikol": "From Spanish 'abacar'..." }

  DictionaryEntry({
    required this.word,
    required this.translations,
    required this.sampleSentences,
    required this.synonyms,
    required this.antonyms,
    required this.etymologies,
  });
}
