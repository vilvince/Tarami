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
  });
}