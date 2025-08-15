import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/quiz_viewmodel.dart';


class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        final result = viewModel.getQuizResult();

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Result content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        // Back arrow
                        GestureDetector(
                          onTap: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
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

                        // Results
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Score
                                Text(
                                  'Score: ${result.score}/${result.totalQuestions}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Congratulations or encouragement
                                Text(
                                  result.isPerfectScore
                                      ? 'Congratulations!'
                                      : 'Better luck next time!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF666666),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Streak and Badge info
                                Column(
                                  children: [
                                    Text(
                                      'Streak: ${result.currentStreak}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Title Badge: ${result.badgeLevel}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 60),

                                // Action buttons
                                Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          viewModel.resetQuiz();
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFC107),
                                          foregroundColor: const Color(0xFF333333),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: const Text(
                                          'Play Again',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.popUntil(context, (route) => route.isFirst);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFC107),
                                          foregroundColor: const Color(0xFF333333),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        child: const Text(
                                          'Return to Home',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),
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