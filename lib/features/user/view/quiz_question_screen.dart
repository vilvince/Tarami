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
        // Handle different quiz states
        if (viewModel.quizState == QuizState.loading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading questions...'),
                ],
              ),
            ),
          );
        }

        if (viewModel.quizState == QuizState.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage ?? 'Unknown error occurred',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.retryQuiz();
                    },
                    child: Text('Retry'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

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
                        // Header with back button and difficulty indicator
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF333333),
                                  size: 28,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFC107).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  viewModel.difficultyDisplayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Progress indicator
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Question ${viewModel.questionNumber} of ${viewModel.totalQuestions}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Streak: ${viewModel.userStats.currentStreak}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: viewModel.questionNumber / viewModel.totalQuestions,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Question and answers
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Question text
                                Text(
                                  question.question,
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
                                      // Safe access to answer states with fallback
                                      AnswerState answerState = AnswerState.none;
                                      if (viewModel.answerStates.length > index) {
                                        answerState = viewModel.answerStates[index];
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: AnswerOption(
                                          label: String.fromCharCode(65 + index), // A, B, C, D
                                          text: question.options[index],
                                          isSelected: viewModel.selectedAnswer == index,
                                          answerState: answerState,
                                          onTap: viewModel.hasAnswered
                                              ? () {} // Disable tap if already answered
                                              : () => viewModel.selectAnswer(index),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Next button
                                if (viewModel.hasAnswered)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 40),
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
                                          viewModel.isLastQuestion ? 'Finish Quiz' : 'Next Question',
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
      // Default state - check if selected
        if (isSelected && answerState == AnswerState.none) {
          backgroundColor = Color(0xFFFFC107).withOpacity(0.1);
          borderColor = Color(0xFFFFC107);
        } else {
          backgroundColor = Colors.grey[50]!;
          borderColor = Colors.grey[300]!;
        }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && answerState == AnswerState.none
              ? [
            BoxShadow(
              color: Color(0xFFFFC107).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getCircleColor(),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getCircleTextColor(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Add icon for correct/incorrect answers
            if (answerState == AnswerState.correct)
              Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 24,
              )
            else if (answerState == AnswerState.incorrect)
              Icon(
                Icons.cancel,
                color: Color(0xFFE53E3E),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getCircleColor() {
    switch (answerState) {
      case AnswerState.correct:
        return Color(0xFF4CAF50);
      case AnswerState.incorrect:
        return Color(0xFFE53E3E);
      default:
        return isSelected ? Color(0xFFFFC107) : Colors.white;
    }
  }

  Color _getCircleTextColor() {
    switch (answerState) {
      case AnswerState.correct:
      case AnswerState.incorrect:
        return Colors.white;
      default:
        return isSelected ? Colors.white : Color(0xFF333333);
    }
  }
}