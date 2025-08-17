import 'package:flutter/material.dart';
import 'package:tarami_application/features/home/view/home_screen.dart';
import 'package:tarami_application/features/dictionary/view/dictionary_screen.dart';
import 'package:tarami_application/features/contribute/view/contribute_screen.dart';
import 'package:tarami_application/features/trivia/view/trivia_screen.dart';
import 'package:tarami_application/features/user/view/user_tab_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarami Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainNavigation(), // Ito na yung dating MainScaffold
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreenPage(),
    DictionaryScreen(),
    ContributeScreenPage(),
    TriviaScreenPage(),
    UserTabScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B2D39), // dark blue background
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white, // active = white
        unselectedItemColor: Colors.grey.shade400, // inactive = light gray
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Contribute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Trivia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
