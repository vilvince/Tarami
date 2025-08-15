import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/quiz_viewmodel.dart';
import 'package:tarami_application/features/user/view/quiz_result_screen.dart';


class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.quizState == QuizState.completed) {
          return QuizResultScreen();
        }

        final question = viewModel.currentQuestion;
        if (question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Question content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        // Back arrow
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF333333),
                              size: 28,
                            ),
                          ),
                        ),

                        const SizedBox(height: 120),

                        // Question and answers
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),

                                // Question number and text
                                Text(
                                  '${viewModel.questionNumber}. ${question.question}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Answer options
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: question.options.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: AnswerOption(
                                          label: String.fromCharCode(65 + index), // A, B, C, D
                                          text: question.options[index],
                                          isSelected: viewModel.selectedAnswer == index,
                                          answerState: viewModel.answerStates[index],
                                          onTap: () => viewModel.selectAnswer(index),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Next button
                                if (viewModel.hasAnswered)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 70),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: viewModel.nextQuestion,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFC107),
                                          foregroundColor: const Color(0xFF333333),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: Text(
                                          viewModel.isLastQuestion ? 'Finish' : 'Next',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Answer Option Widget
class AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final AnswerState answerState;
  final VoidCallback onTap;

  const AnswerOption({
    Key? key,
    required this.label,
    required this.text,
    required this.isSelected,
    required this.answerState,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor = const Color(0xFF333333);

    switch (answerState) {
      case AnswerState.correct:
        backgroundColor = const Color(0xFFE8F5E8);
        borderColor = const Color(0xFF4CAF50);
        break;
      case AnswerState.incorrect:
        backgroundColor = const Color(0xFFFFF3F3);
        borderColor = const Color(0xFFE53E3E);
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        borderColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              '$label.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}