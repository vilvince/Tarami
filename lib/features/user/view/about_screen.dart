import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 12.0), // Adjusted padding
              child: Row(
                children: [
                  IconButton(
                    color: Colors.black,
                    iconSize: 28,
                    icon: const Icon(Icons.arrow_back_ios_new),
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
            ),

            Expanded( // Use Expanded to allow the content to take available vertical space
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding for the content
                child: Center( // Center the text block
                  child: SingleChildScrollView( // In case content is too long for the screen
                    child: const Text(
                      'TARAMI (Terminology for Albay’s Root Accent Mobile Integration) is a mobile dictionary app that preserves and promotes the dialects of Albay. Users can search for words from Central Bikol, East Miraya, West Miraya, and Libon Bikol, and see their definitions, translations, parts of speech, pronunciation, and example sentences. The app also includes a single interactive Game where users can test their knowledge and improve familiarity with the dialect vocabulary. TARAMI makes learning the Albay dialects easy, engaging, and accessible for everyone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
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
