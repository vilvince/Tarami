class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}