import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SubmissionModel {
  final String email;
  final String submittedWord;
  final String dialect;
  final String translation;
  final String date;
  final String partOfSpeech;
  final String status; // Approved, Denied, Flagged
  final String? rejectionReason;
  final String? reviewNotes;

  // ✅ Extra fields for modal
  final String phonetic;
  final String tagalog;
  final String definition;
  final String exampleInDialect;
  final String exampleInEnglish;
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
    required this.exampleInDialect,
    required this.exampleInEnglish,
    this.synonyms = "",
    this.rejectionReason,
    this.reviewNotes,
  });


  factory SubmissionModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final combinedExample = data['example_sentence'] as String? ?? '|';
    final exampleParts = combinedExample.split('|');
    final dialectExample = exampleParts.isNotEmpty ? exampleParts[0] : 'N/A';
    final englishExample = exampleParts.length > 1 ? exampleParts[1] : 'N/A';

    String capitalize(String s) {
      if (s.isEmpty) return '';
      return s[0].toUpperCase() + s.substring(1);
    }

    String formatDate(Timestamp? ts) {
      if (ts == null) return 'N/A';
      return DateFormat('MM/dd/yyyy').format(ts.toDate());
    }


    return SubmissionModel(
      email: data['submitted_by_email'] ?? 'N/A',
      submittedWord: data['word'] ?? '',
      dialect: data['dialect'] ?? '',
      translation: data['translation'] ?? '',
      date: formatDate(data['reviewed_at'] as Timestamp?),
      partOfSpeech: data['part_of_speech'] ?? '',
      status: capitalize(data['status'] ?? ''),
      phonetic: data['phonetics'] ?? '',
      tagalog: data['tagalog_translation'] ?? '',
      definition: data['definition'] ?? '',
      exampleInDialect: dialectExample,
      exampleInEnglish: englishExample,
      synonyms: data['synonyms'] ?? '',

      // 🔽 ADD THESE TWO LINES 🔽
      rejectionReason: data['rejection_reason'], // Pulls from Firestore
      reviewNotes: data['review_notes'],
    );
  }
}

