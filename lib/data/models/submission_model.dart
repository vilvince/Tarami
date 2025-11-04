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
  final String exampleSentence;
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
    required this.exampleSentence,
    required this.synonyms,
    this.rejectionReason,
  });

  factory Submission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper to capitalize status
    String capitalize(String s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

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
      exampleSentence: data['example_sentence'] ?? '',
      synonyms: data['synonyms'] ?? '',
      rejectionReason: data['rejection_reason'], // ✅ READ THE NEW FIELD
    );
  }
}