import 'package:flutter/material.dart';


class dictionary extends StatefulWidget {
  const dictionary({super.key});

  @override
  State<dictionary> createState() => _dictionaryState();
}

class _dictionaryState extends State<dictionary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text ('Dictionary Page'),
      ),
    );

  }
}
