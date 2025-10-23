import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/theme.dart';
import 'features/trivia/viewmodel/trivia_admin_vm.dart';
import 'features/trivia/pages/trivia_page.dart';
import 'features/contribute/pages/contribute_page.dart';
import 'features/contribute/viewmodel/contribute_vm.dart';
import 'features/home/viewmodel/home_vm.dart';
import 'features/home/pages/home_page.dart';
import 'features/inbox/viewmodel/inbox_vm.dart';
import 'features/inbox/pages/inbox_page.dart';
import 'features/user_management/viewmodel/user_vm.dart';
import 'features/user_management/pages/user_page.dart';
import 'features/submissions/viewmodel/submission_vm.dart';
import 'features/submissions/pages/submission_page.dart';
import 'features/word_management/viewmodel/word_vm.dart';
import 'features/word_management/pages/word_page.dart';
import 'package:tarami_application/app/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADD THIS
import 'package:tarami_application/admin/AdminServices/admin_auth_service.dart'; // ADD THIS

void main() async {
  // ADD THESE LINES
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDFFn7ZS8CY57LImCPccpIJoCmMmoVLHOQ",
      authDomain: "tarami.firebaseapp.com",
      projectId: "tarami",
      storageBucket: "tarami.firebasestorage.app",
      messagingSenderId: "719315807707",
      appId: "1:719315807707:web:c4192279cbe533a2f60bfe",
    ),
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ADD AdminAuthService
        Provider<AdminAuthService>(
          create: (_) => AdminAuthService(),
        ),

        // Your existing ViewModels
        ChangeNotifierProvider(create: (_) => TriviaAdminVM()),
        ChangeNotifierProvider(create: (_) => AdminContributeViewModel()),
        ChangeNotifierProvider(create: (_) => HomeVM()),
        ChangeNotifierProvider(create: (_) => InboxVM()),
        ChangeNotifierProvider(create: (_) => UserVM()),
        ChangeNotifierProvider(create: (_) => SubmissionVM()),
        ChangeNotifierProvider(create: (_) => WordVM()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tarami Admin',
        theme: buildAdminTheme().copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoTransitionsBuilder(),
              TargetPlatform.iOS: NoTransitionsBuilder(),
              TargetPlatform.windows: NoTransitionsBuilder(),
              TargetPlatform.linux: NoTransitionsBuilder(),
              TargetPlatform.macOS: NoTransitionsBuilder(),
              TargetPlatform.fuchsia: NoTransitionsBuilder(),
            },
          ),
        ),

        // ADD AUTH STATE MANAGEMENT
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Show loading while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFFE8F1F9),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFBC02D),
                  ),
                ),
              );
            }

            // Check if user is logged in
            if (snapshot.hasData) {
              // Verify admin access
              return FutureBuilder<bool>(
                future: context.read<AdminAuthService>().isAdmin(),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      backgroundColor: Color(0xFFE8F1F9),
                      body: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFBC02D),
                        ),
                      ),
                    );
                  }

                  // If admin, go to home/dashboard
                  if (adminSnapshot.data == true) {
                    return const HomePage();
                  }

                  // Not admin, logout and go to login
                  FirebaseAuth.instance.signOut();
                  return const LoginPage();
                },
              );
            }

            // Not logged in, show login page
            return const LoginPage();
          },
        ),

        // Keep your existing routes
        routes: {
          '/login': (_) => const LoginPage(),
          '/admin/trivia': (_) => const TriviaPage(),
          '/admin/contribute': (_) => const ContributePage(),
          '/admin/home': (_) => const HomePage(),
          '/admin/inbox': (_) => const InboxPage(),
          '/admin/users': (_) => const UserPage(),
          '/admin/submissions': (_) => const SubmissionPage(),
          '/admin/words': (_) => const WordPage(),
        },
      ),
    );
  }
}

// Transition remover
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return child;
  }
}