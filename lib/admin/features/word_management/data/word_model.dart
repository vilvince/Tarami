class WordModel {
  final String word;
  final String dialect;

  final String? translation;
  final String? phonetic;
  final String? tagalog;
  final String? partOfSpeech;
  final String? definition;
  final String? exampleDialect;
  final String? exampleEnglish;
  final String? synonyms;

  WordModel({
    required this.word,
    required this.dialect,
    this.translation,
    this.phonetic,
    this.tagalog,
    this.partOfSpeech,
    this.definition,
    this.exampleDialect,
    this.exampleEnglish,
    this.synonyms,
  });
}
