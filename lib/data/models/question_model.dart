class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String difficulty;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.difficulty = 'easy',
  });

  // Create Question from Firestore document
  factory Question.fromFirestore(String id, Map<String, dynamic> data) {
    return Question(
      id: id,
      question: data['question'] ?? '',
      options: List<String>.from(data['choices'] ?? []), // 👈 map Firestore 'choices'
      correctAnswerIndex: data['correct_answer'] ?? 0,  // 👈 map Firestore 'correct_answer'
      difficulty: data['difficulty'] ?? 'easy',
    );
  }

  // Convert Question to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'choices': options,              // 👈 save back as 'choices'
      'correct_answer': correctAnswerIndex, // 👈 save back as 'correct_answer'
      'difficulty': difficulty,
    };
  }
}
