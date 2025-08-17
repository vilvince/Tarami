// contribute_model.dart
class ContributeModel {
  final String dialect;
  final String word;
  final String translation;
  final String phonetic;
  final String tagalogTranslation;
  final String partOfSpeech;
  final String definition;
  final String? etymology;
  final String example;
  final String? synonyms;

  ContributeModel({
    required this.dialect,
    required this.word,
    required this.translation,
    required this.phonetic,
    required this.tagalogTranslation,
    required this.partOfSpeech,
    required this.definition,
    this.etymology,
    required this.example,
    this.synonyms,
  });

  factory ContributeModel.fromJson(Map<String, dynamic> json) {
    return ContributeModel(
      dialect: json['dialect'] ?? '',
      word: json['word'] ?? '',
      translation: json['translation'] ?? '',
      phonetic: json['phonetic'] ?? '',
      tagalogTranslation: json['tagalog_translation'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      definition: json['definition'] ?? '',
      etymology: json['etymology'],
      example: json['example'] ?? '',
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
      'etymology': etymology,
      'example': example,
      'synonyms': synonyms,
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
    String? etymology,
    String? example,
    String? synonyms,
  }) {
    return ContributeModel(
      dialect: dialect ?? this.dialect,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      phonetic: phonetic ?? this.phonetic,
      tagalogTranslation: tagalogTranslation ?? this.tagalogTranslation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      etymology: etymology ?? this.etymology,
      example: example ?? this.example,
      synonyms: synonyms ?? this.synonyms,
    );
  }
}

// Optional: Dropdown helper
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
}
