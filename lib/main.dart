import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <== Add this
import 'package:tarami_application/features/user/view/quiz_start_screen.dart';
import 'package:tarami_application/widgets/main_scaffold.dart';
import 'package:tarami_application/features/user/view/submission_screen.dart';
import 'package:tarami_application/features/user/view/faqs_screen.dart';
import 'package:tarami_application/features/user/view/favorite_screen.dart';
import 'package:tarami_application/features/user/view/recent_screen.dart';
import 'package:tarami_application/features/user/view/about_screen.dart';
import 'package:tarami_application/features/user/view/profile_screen.dart';
import 'package:tarami_application/features/user/viewmodel/profile_viewmodel.dart';
import 'package:tarami_application/features/user/viewmodel/submission_viewmodel.dart';
import 'package:tarami_application/features/user/viewmodel/favorite_viewmodel.dart';
import 'package:tarami_application/features/user/viewmodel/recent_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarami_application/features/auth/view/login.dart';
import 'package:tarami_application/features/dictionary/viewmodel/dictionary_view_model.dart'; // ✅ correct path
import 'package:firebase_core/firebase_core.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SubmissionViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (_) => RecentViewModel()),
        ChangeNotifierProvider(create: (_) => DictionaryViewModel()),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(), // 👈 Set global font here
        primarySwatch: Colors.blue,
        useMaterial3: true, // optional, depending on your setup
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.white,              // 👈 active loader color
          circularTrackColor: Color(0xFF0B1E2D), // 👈 background circle
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const MainScaffold();
          }

          {
            return const LoginPage();
          }
        },
      ),
      routes: {
        '/submission': (context) => const SubmissionScreen(),
        '/faqs': (context) => const FaqsScreen(),
        '/favorite': (context) => const FavoriteScreen(),
        '/recent': (context) => const RecentScreen(),
        '/about': (context) => const AboutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/game': (context) => const QuizStartScreen(),
      },
    );
  }
}
