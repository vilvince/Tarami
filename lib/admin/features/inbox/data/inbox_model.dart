// inbox_model.dart
class InboxItem {
  final String email;
  final String submittedWord;
  final String dialect;
  final String translation;
  final String date; // keep as String for display simplicity
  final String partOfSpeech;

  // ✅ New fields you requested
  final String phonetic;
  final String tagalog;
  final String definition;
  final String example;
  final String synonyms;
  final String? rejectionReason;

  String status; // "Pending" or "Reviewed"

  InboxItem({
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
    this.rejectionReason,
  });
}