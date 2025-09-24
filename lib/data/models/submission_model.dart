// lib/data/models/submission_model.dart
class Submission {
  final String id;
  final String word;
  final String dialect;
  final DateTime date;
  final String status; // e.g., "Pending", "Approved", "Denied", "Flagged"
  final String translation;
  final String phonetics;
  final String partOfSpeech;
  final String tagalog;
  final String definition;
  final String exampleSentence;
  final String synonyms;
  final String? etymology; // Optional field

  Submission({
    required this.id,
    required this.word,
    required this.dialect,
    required this.date,
    required this.status,
    required this.translation,
    required this.phonetics,
    required this.partOfSpeech,
    required this.tagalog,
    required this.definition,
    required this.exampleSentence,
    required this.synonyms,
    this.etymology,
  });
}