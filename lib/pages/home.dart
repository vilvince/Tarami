import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'T', style: TextStyle(color: Colors.blue)),
                  TextSpan(text: 'A', style: TextStyle(color: Colors.orange)),
                  TextSpan(text: 'R', style: TextStyle(color: Colors.blue)),
                  TextSpan(text: 'A', style: TextStyle(color: Colors.blue)),
                  TextSpan(text: 'M', style: TextStyle(color: Colors.blue)),
                  TextSpan(text: 'I', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.mic, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Welcome Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to TARAMI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Lorem Hello Worrrld ipsum dolor sit amet, consectetur adipiscing elit, '
                          'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Horizontal Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cardBox(),
                cardBox(),
              ],
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'More >',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cardBox() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: const Column(
          children: [
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 10),
            Text(
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
