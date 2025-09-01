import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/theme.dart';
import 'features/trivia/viewmodel/trivia_admin_vm.dart';
import 'features/trivia/pages/trivia_page.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tarami Admin',
        theme: buildAdminTheme(),
        initialRoute: '/admin/trivia',
        routes: {
          '/admin/trivia': (_) => const TriviaPage(),
        },
      ),
    );
  }
}
