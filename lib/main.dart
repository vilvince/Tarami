import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/auth/view/login.dart';
import 'package:tarami_application/features/dictionary/viewmodel/dictionary_view_model.dart'; // ✅ correct path

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DictionaryViewModel(), // ✅ class from correct file
        ),
        // Add more providers here if needed
      ],
      child: const TaramiApp(),
    ),
  );
}

class TaramiApp extends StatelessWidget {
  const TaramiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarami App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
      ),
      home: const LoginPage(), // Starting page
    );
  }
}
