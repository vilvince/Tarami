import 'package:flutter/material.dart';

BottomNavigationBar buildBottomNavBar(int currentIndex, Function(int) onTabTapped) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTabTapped,
    type: BottomNavigationBarType.fixed,
    backgroundColor: const Color(0xFF0d2334),
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white60,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Dictionary'),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Contribute'),
      BottomNavigationBarItem(icon: Icon(Icons.emoji_objects), label: 'Trivia'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
    ],
  );
}
