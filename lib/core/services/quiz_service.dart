import 'package:tarami_application/data/models/question_model.dart';


class QuizService {
  // Sample questions - replace with your database calls
  static List<Question> getSampleQuestions() {
    return [
      Question(
        id: '1',
        question: 'What is the Central Bikol term for "house"?',
        options: ['Balay', 'Harong', 'Tabon', 'Lugar'],
        correctAnswerIndex: 1,
        difficulty: 'easy',
      ),
      Question(
        id: '2',
        question: 'What does "uran" mean in English?',
        options: ['Sun', 'Moon', 'Rain', 'Wind'],
        correctAnswerIndex: 2,
        difficulty: 'easy',
      ),
      Question(
        id: '3',
        question: 'What is "morning" in Central Bicol?',
        options: ['Bangag', 'Aga', 'Hapon', 'Duman'],
        correctAnswerIndex: 1,
        difficulty: 'easy',

      ),
      Question(
        id: '4',
        question: 'What does "harong" mean?',
        options: ['Food', 'Water', 'House', 'Tree'],
        correctAnswerIndex: 2,
        difficulty: 'easy',
      ),
      Question(
        id: '5',
        question: 'What is the West Miraya word for "rice"?',
        options: ['umay', 'Dagat', 'Sapa', 'Ulog'],
        correctAnswerIndex: 0,
        difficulty: 'easy',
      ),
      Question(
        id: '6',
        question: 'What does "kaon" mean?',
        options: ['Sleep', 'Eat', 'Walk', 'Run'],
        correctAnswerIndex: 1,
        difficulty: 'easy',
      ),
      Question(
        id: '7',
        question: 'What is "good morning" in Bicol?',
        options: ['Maayong aga', 'Kumusta ka', 'Salamat', 'Paaram'],
        correctAnswerIndex: 0,
        difficulty: 'easy',
      ),
      Question(
        id: '8',
        question: 'What does "lugar" mean?',
        options: ['Time', 'Place', 'Person', 'Thing'],
        correctAnswerIndex: 1,
        difficulty: 'easy',
      ),
      Question(
        id: '9',
        question: 'What is the Bicol term for "thank you"?',
        options: ['Kumusta', 'Salamat', 'Paaram', 'Sige'],
        correctAnswerIndex: 1,
        difficulty: 'easy',
      ),
    ];
  }
}
