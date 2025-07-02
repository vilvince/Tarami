import 'package:flutter/material.dart';
import 'package:tarami_application/pages/home.dart';
import 'package:tarami_application/pages/dictionary.dart';
import 'package:tarami_application/pages/contribute.dart';
import 'package:tarami_application/pages/trivia.dart';
import 'package:tarami_application/pages/userTab.dart';
import 'package:tarami_application/widgets/bottom_nav.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Home(),
    dictionary(),
    contribute(),
    trivia(),
    userTab(),
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
