class SubmissionModel {
  final String email;
  final String submittedWord;
  final String dialect;
  final String translation;
  final String date;
  final String partOfSpeech;
  final String status; // Approved, Denied, Flagged

  SubmissionModel({
    required this.email,
    required this.submittedWord,
    required this.dialect,
    required this.translation,
    required this.date,
    required this.partOfSpeech,
    required this.status,
  });
}
