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

// In quiz_start_screen.dart
class QuizStartView extends StatefulWidget {
  const QuizStartView({Key? key}) : super(key: key);

  @override
  State<QuizStartView> createState() => _QuizStartViewState();
}

class _QuizStartViewState extends State<QuizStartView> {
  @override
  void initState() {
    super.initState();
    // Initialize game when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.quizState == QuizState.loading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.quizState == QuizState.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.initializeGame,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        // Back button
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


                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Badge Level',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        viewModel.userStats.badgeLevel,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFC107),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const TaramLogo(),
                                SizedBox(height: 40),
                                SizedBox(
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