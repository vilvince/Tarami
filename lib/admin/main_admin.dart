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



void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TriviaAdminVM()),
        ChangeNotifierProvider(create: (_) => ContributeVM()),
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
          // ✅ REMOVE PAGE TRANSITIONS GLOBALLY
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
        initialRoute: '/login',
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

// ✅ Transition remover
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
