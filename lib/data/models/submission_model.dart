import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String exampleInDialect;
  final String exampleInEnglish;
  final String synonyms;
  final String? rejectionReason;

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
    required this.exampleInDialect,
    required this.exampleInEnglish,
    required this.synonyms,
    this.rejectionReason,
  });

  factory Submission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper to capitalize status
    String capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

    final String combinedExample = data['example_sentence'] as String? ?? '';
    final List<String> parts = combinedExample.split('|');

    // Get the first part (Dialect) or empty if missing
    final String dialectExample = parts.isNotEmpty ? parts[0].trim() : '';

    // Get the second part (English) or empty if missing
    final String englishExample = parts.length > 1 ? parts[1].trim() : '';

    return Submission(
      id: doc.id,
      word: data['word'] ?? '',
      dialect: data['dialect'] ?? '',
      date: (data['date_submitted'] as Timestamp? ?? Timestamp.now()).toDate(),
      status: capitalize(data['status'] ?? 'Pending'),
      translation: data['translation'] ?? '',
      phonetics: data['phonetics'] ?? '',
      tagalog: data['tagalog_translation'] ?? '',
      definition: data['definition'] ?? '',
      partOfSpeech: data['part_of_speech'] ?? '',
      exampleInDialect: dialectExample,
      exampleInEnglish: englishExample,
      synonyms: data['synonyms'] ?? '',
      rejectionReason: data['rejection_reason'] ?? data['review_notes'],
    );
  }
}