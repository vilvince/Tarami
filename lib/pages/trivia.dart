import 'package:flutter/material.dart';


class trivia extends StatefulWidget {
  const trivia({super.key});

  @override
  State<trivia> createState() => _triviaState();
}

class _triviaState extends State<trivia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Triv'
          'ia Page')),
    );
  }
}
