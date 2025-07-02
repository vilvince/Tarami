import 'package:flutter/material.dart';
import 'package:tarami_application/MainScaffold.dart'; // New shared layout

void main() {
  runApp(const TaramiApp());
}

class TaramiApp extends StatelessWidget {
  const TaramiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(),
    );
  }
}
