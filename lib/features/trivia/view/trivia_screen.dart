import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/trivia/viewmodel/trivia_viewmodel.dart';

class TriviaScreenPage extends StatelessWidget {
  const TriviaScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TriviaViewModel(),
      child: Consumer<TriviaViewModel>(
        builder: (context, vm, _) {
          return Container(
            color: const Color(0xFF0A284F),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'TRIVIA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 24,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: vm.triviaItems
                              .map((text) => _buildTriviaCard(text))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildTriviaCard(InlineSpan text) {
    return Center(
      child: SizedBox(
        width: 450, // 🔹 fixed width para consistent sa lahat ng device
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: text,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
