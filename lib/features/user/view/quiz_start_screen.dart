import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/quiz_viewmodel.dart';
import 'package:tarami_application/features/user/view/quiz_question_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

class QuizStartView extends StatefulWidget {
  const QuizStartView({Key? key}) : super(key: key);

  @override
  State<QuizStartView> createState() => _QuizStartViewState();
}

class _QuizStartViewState extends State<QuizStartView> {
  bool _isOnline = true;
  bool _hasCheckedConnection = false;

  @override
  void initState() {
    super.initState();
    // Check connection and initialize game
    _initializeWithConnectivityCheck();
    _listenToConnectivity();
  }

  // Check connection before initializing game
  Future<void> _initializeWithConnectivityCheck() async {
    final hasInternet = await _hasInternetConnection();
    setState(() {
      _isOnline = hasInternet;
      _hasCheckedConnection = true;
    });

    if (hasInternet) {
      // Only initialize game if online
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<QuizViewModel>().initializeGame();
        }
      });
    }
  }

  // Check if has internet connection
  Future<bool> _hasInternetConnection() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Listen to connectivity changes
  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  // Show offline dialog
  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.redAccent),
              const SizedBox(width: 10),
              Expanded( // 👈 allows wrapping to avoid overflow
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 18, // 👈 adjust this to change text size
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'You need an internet connection to play the games.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(fontSize: 19, color: Color(
                  0xFF000000))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking connection
    if (!_hasCheckedConnection) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show offline screen if no connection
    if (!_isOnline) {
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

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 100,
                                color: Colors.orange[300],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Internet Connection',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'You need an internet connection to play the game.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Retry connection check
                                    final hasInternet = await _hasInternetConnection();
                                    if (hasInternet) {
                                      setState(() {
                                        _isOnline = true;
                                      });
                                      // Initialize game now that we're online
                                      if (mounted) {
                                        context.read<QuizViewModel>().initializeGame();
                                      }
                                    } else {
                                      // Still offline, show dialog
                                      _showOfflineDialog();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC107),
                                    foregroundColor: const Color(0xFF333333),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.refresh),
                                      SizedBox(width: 8),
                                      Text(
                                        'TRY AGAIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
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
              ),
            ],
          ),
        ),
      );
    }

    // Normal online flow - show quiz start screen
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.initializeGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: const Color(0xFF333333),
                    ),
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
                                    onPressed: () async {
                                      // CHECK INTERNET BEFORE STARTING QUIZ
                                      final hasInternet = await _hasInternetConnection();
                                      if (!hasInternet) {
                                        _showOfflineDialog();
                                        return;
                                      }

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