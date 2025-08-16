import 'package:flutter/material.dart';
import 'package:tarami_application/features/home/view/home_screen.dart';
import 'package:tarami_application/features/dictionary/view/dictionary_screen.dart';
import 'package:tarami_application/features/contribute/view/contribute_screen.dart';
import 'package:tarami_application/features/trivia/view/trivia_screen.dart';
import 'package:tarami_application/features/user/view/user_tab_screen.dart';

import 'package:tarami_application/widgets/bottom_nav.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    Dictionary(),
    ContributeScreen(),
    TriviaScreen(),
    UserTabScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: buildBottomNavBar(_currentIndex, _onTabTapped),
    );
  }
}
