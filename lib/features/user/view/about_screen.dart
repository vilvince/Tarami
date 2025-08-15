import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Back button and Title
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 12.0), // Adjusted padding
              child: Row(
                children: [
                  IconButton(
                    color: Colors.black,
                    iconSize: 28, // Slightly smaller
                    icon: const Icon(Icons.arrow_back_ios_new), // Different back icon
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 84),
                  const Text(
                    'About Us',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                    ),
                  ),
                ],
              ),
            ), // <--- Padding for header ends here

            // Main Content Area
            Expanded( // Use Expanded to allow the content to take available vertical space
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding for the content
                child: Center( // Center the text block
                  child: SingleChildScrollView( // In case content is too long for the screen
                    child: const Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                          'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                          'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6, // Line height
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Optional: Add some space at the bottom
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
