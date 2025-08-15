import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/quiz_viewmodel.dart';
import 'package:tarami_application/features/user/view/quiz_question_screen.dart';

class QuizStartScreen extends StatelessWidget {
  const QuizStartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizViewModel(),
      child: const QuizStartView(),
    );
  }
}

class QuizStartView extends StatelessWidget {
  const QuizStartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Remove the Scaffold's background color
      // backgroundColor: const Color(0xFF2C5F7C), // Removed this line
      body: SafeArea(
        child: Column(
          children: [

            // Main content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Back arrow inside container
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

                    //const SizedBox(height: 40),
                    // Logo and button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const TaramLogo(),
                            Consumer<QuizViewModel>(
                              builder: (context, viewModel, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      viewModel.startQuiz();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChangeNotifierProvider.value(
                                                value: viewModel,
                                                child: const QuizQuestionScreen(),
                                              ),
                                        ),
                                      );
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
                                      'START QUIZ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // const SizedBox(height: 10),
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
  }
}

// Custom TARAM Logo Widget (remains the same)
class TaramLogo extends StatelessWidget {
  const TaramLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Image(
          image: AssetImage('assets/TaramiLogo.png'),
            width: 300,
            height: 350,
          ),
        ),

      ],
    );
  }
}
