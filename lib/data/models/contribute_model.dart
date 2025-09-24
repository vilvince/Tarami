// contribute_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ContributeModel {
  final String dialect;
  final String word;
  final String translation;
  final String phonetic;
  final String tagalogTranslation;
  final String partOfSpeech;
  final String definition;
  final String exampleSentenceInDialect;
  final String exampleSentenceInEnglish;
  final String? synonyms;

  // Additional fields for Firebase
  final String? submittedId;
  final String? submittedBy;
  final DateTime? dateSubmitted;
  final String? status;


  ContributeModel({
    required this.dialect,
    required this.word,
    required this.translation,
    required this.phonetic,
    required this.tagalogTranslation,
    required this.partOfSpeech,
    required this.definition,
    required this.exampleSentenceInDialect,
    required this.exampleSentenceInEnglish,
    this.synonyms,
    this.submittedId,
    this.submittedBy,
    this.dateSubmitted,
    this.status,
  });

  factory ContributeModel.fromFirestore(Map<String, dynamic> json) {
    // Parse example sentences (stored as combined string in Firebase)
    final exampleSentence = json['example_sentence'] ?? '';
    final examples = exampleSentence.split('|');

    return ContributeModel(
      dialect: json['dialect'] ?? '',
      word: json['word'] ?? '',
      translation: json['translation'] ?? '',
      phonetic: json['phonetics'] ?? '',
      tagalogTranslation: json['tagalog_translation'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      definition: json['definition'] ?? '',
      exampleSentenceInDialect: examples.isNotEmpty ? examples[0] : '',
      exampleSentenceInEnglish: examples.length > 1 ? examples[1] : '',
      synonyms: json['synonyms']?.isEmpty == true ? null : json['synonyms'],
      submittedId: json['submitted_id'],
      submittedBy: json['submitted_by'],
      dateSubmitted: json['date_submitted'] != null
          ? (json['date_submitted'] as Timestamp).toDate()
          : null,
      status: json['status'],
    );
  }

  // For backwards compatibility with existing code
  factory ContributeModel.fromJson(Map<String, dynamic> json) {
    return ContributeModel(
      dialect: json['dialect'] ?? '',
      word: json['word'] ?? '',
      translation: json['translation'] ?? '',
      phonetic: json['phonetic'] ?? '',
      tagalogTranslation: json['tagalog_translation'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      definition: json['definition'] ?? '',
      exampleSentenceInDialect: json['example_in_dialect'] ?? '',
      exampleSentenceInEnglish: json['example_in_english'] ?? '',
      synonyms: json['synonyms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dialect': dialect,
      'word': word,
      'translation': translation,
      'phonetic': phonetic,
      'tagalog_translation': tagalogTranslation,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example_in_dialect': exampleSentenceInDialect,
      'example_in_english': exampleSentenceInEnglish,
      'synonyms': synonyms,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dialect': dialect,
      'word': word,
      'translation': translation,
      'phonetics': phonetic, // Firebase uses 'phonetics'
      'tagalog_translation': tagalogTranslation,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example_sentence': '$exampleSentenceInDialect|$exampleSentenceInEnglish',
      'synonyms': synonyms ?? '',
      if (submittedId != null) 'submitted_id': submittedId,
      if (submittedBy != null) 'submitted_by': submittedBy,
      if (dateSubmitted != null) 'date_submitted': Timestamp.fromDate(dateSubmitted!),
      if (status != null) 'status': status,
    };
  }

  ContributeModel copyWith({
    String? dialect,
    String? word,
    String? translation,
    String? phonetic,
    String? tagalogTranslation,
    String? partOfSpeech,
    String? definition,
    String? exampleSentenceInDialect,
    String? exampleSentenceInEnglish,
    String? synonyms,
    String? submittedId,
    String? submittedBy,
    DateTime? dateSubmitted,
    String? status,
  }) {
    return ContributeModel(
      dialect: dialect ?? this.dialect,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      phonetic: phonetic ?? this.phonetic,
      tagalogTranslation: tagalogTranslation ?? this.tagalogTranslation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      exampleSentenceInDialect: exampleSentenceInDialect ?? this.exampleSentenceInDialect,
      exampleSentenceInEnglish: exampleSentenceInEnglish ?? this.exampleSentenceInEnglish,
      synonyms: synonyms ?? this.synonyms,
      submittedId: submittedId ?? this.submittedId,
      submittedBy: submittedBy ?? this.submittedBy,
      dateSubmitted: dateSubmitted ?? this.dateSubmitted,
      status: status ?? this.status,
    );
  }

  // Helper methods
  String get statusDisplayText {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Under Review';
      case 'accepted':
        return 'Accepted';
      case 'denied':
        return 'Rejected';
      case 'flagged':
        return 'Flagged';
      default:
        return 'Unknown';
    }
  }

  String get formattedDate {
    if (dateSubmitted == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateSubmitted!);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateSubmitted!.day}/${dateSubmitted!.month}/${dateSubmitted!.year}';
    }
  }

  @override
  String toString() {
    return 'ContributeModel(word: $word, dialect: $dialect, status: $status)';
  }
}

// Dropdown helper (keeping your original structure)
class ContributeDropdowns {
  static const List<String> dialects = [
    'Central Bikol',
    'West Miraya',
    'East Miraya',
    'Libon Bikol',
  ];

  static const List<String> partsOfSpeech = [
    'Noun', 'Verb', 'Adjective', 'Adverb', 'Pronoun', 'Conjunction', 'Preposition', 'Interjection'
  ];

  static const List<String> submissionStatus = [
    'pending',
    'accepted',
    'denied',
    'flagged'
  ];
}

