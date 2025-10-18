class SubmissionModel {
  final String email;
  final String submittedWord;
  final String dialect;
  final String translation;
  final String date;
  final String partOfSpeech;
  final String status; // Approved, Denied, Flagged

  // ✅ Extra fields for modal
  final String phonetic;
  final String tagalog;
  final String definition;
  final String example;
  final String synonyms;

  SubmissionModel({
    required this.email,
    required this.submittedWord,
    required this.dialect,
    required this.translation,
    required this.date,
    required this.partOfSpeech,
    required this.status,
    this.phonetic = "",
    this.tagalog = "",
    this.definition = "",
    this.example = "",
    this.synonyms = "",
  });
}
