class TriviaModel {
  final String category;
  final String text;
  final List<ExampleWord>? examples;

  TriviaModel({
    required this.category,
    required this.text,
    this.examples,
  });

  factory TriviaModel.fromJson(Map<String, dynamic> json) {
    return TriviaModel(
      category: json['category'] ?? '',
      text: json['text'] ?? '',
      examples: json['examples'] != null
          ? List<ExampleWord>.from(
          (json['examples'] as List).map((e) => ExampleWord.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'text': text,
      'examples': examples?.map((e) => e.toJson()).toList(),
    };
  }

  TriviaModel copyWith({
    String? category,
    String? text,
    List<ExampleWord>? examples,
  }) {
    return TriviaModel(
      category: category ?? this.category,
      text: text ?? this.text,
      examples: examples ?? this.examples,
    );
  }
}

class ExampleWord {
  final String word;
  final String meaning;

  ExampleWord({required this.word, required this.meaning});

  factory ExampleWord.fromJson(Map<String, dynamic> json) {
    return ExampleWord(
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
    };
  }

  ExampleWord copyWith({String? word, String? meaning}) {
    return ExampleWord(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
    );
  }
}
