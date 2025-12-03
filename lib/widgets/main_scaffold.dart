import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
// ✅ Import your Dictionary ViewModel
import 'package:tarami_application/features/dictionary/viewmodel/dictionary_view_model.dart';

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

  static _MainScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainScaffoldState>();
  }
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreenPage(),
    Dictionary(),
    ContributeScreenPage(),
    TriviaScreenPage(),
    UserTabScreen(),
  ];

  void _onTabTapped(int index) {
    // ✅ LOGIC: If the target tab is Dictionary (Index 1)
    // We reset the state regardless of whether we came from another tab
    // or clicked the same tab again.
    if (index == 1) {
      // Access the ViewModel without listening (listen: false)
      final dictVm = Provider.of<DictionaryViewModel>(context, listen: false);

      // 1. Clear the selected word (This takes user back to list view)
      dictVm.resetState();

      // 2. Optional: If you also want to clear the search text when switching tabs:
      // dictVm.searchWords("");
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // This method is called from other screens (like Home Search) to switch tabs
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack if you want to keep the scroll position of OTHER tabs
      // but since you want Dictionary to refresh, _pages[_currentIndex] is fine.
      body: _pages[_currentIndex],
      bottomNavigationBar: buildBottomNavBar(_currentIndex, _onTabTapped),
    );
  }
}