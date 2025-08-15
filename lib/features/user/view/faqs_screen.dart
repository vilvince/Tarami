import 'package:flutter/material.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is Tarami?',
      'answer':
      'Tarami is a digital dictionary app that helps users translate Albay dialects into Tagalog and English, and vice versa. It promotes cultural preservation and language learning.'
    },
    {
      'question': 'What dialects are included in Tarami?',
      'answer': 'Currently, Tarami includes Albay dialects like Bicolano, Legazpeño, etc.'
    },
    {
      'question': 'How can I suggest a new word or translation?',
      'answer':
      'Tap on "Contribute" in the navigation bar and fill out the word submission form.'
    },
    {
      'question': 'Can I edit or delete my submitted suggestions?',
      'answer': 'No, submissions cannot be edited once sent. You may contact support for corrections.'
    },
    {
      'question': 'Are all words verified by language experts?',
      'answer': 'Yes, all entries are reviewed and verified by language experts before being approved.'
    },
    {
      'question': 'Can I use Tarami for school projects or research?',
      'answer': 'Yes! You may use Tarami as a reference tool with proper citation.'
    },
    {
      'question': 'How can I give feedback or report an error?',
      'answer': 'Go to "User" > "About Us" > "Contact" to submit your feedback or report errors.'
    },
    {
      'question': 'Can I edit or delete my submitted suggestions?',
      'answer': 'No, submissions cannot be edited once sent. You may contact support for corrections.'
    },
    {
      'question': 'Are all words verified by language experts?',
      'answer': 'Yes, all entries are reviewed and verified by language experts before being approved.'
    },
    {
      'question': 'Can I use Tarami for school projects or research?',
      'answer': 'Yes! You may use Tarami as a reference tool with proper citation.'
    },
    {
      'question': 'How can I give feedback or report an error?',
      'answer': 'Go to "User" > "About Us" > "Contact" to submit your feedback or report errors.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
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
                  const SizedBox(width: 107),
                  const Text(
                    'FAQs',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Title and subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Got questions? Here are the answers to the most common ones about the TARAMI app!',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // FAQ list
            Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final item = faqs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder( // Para sa border ng tile kapag NAKA-EXPAND
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide.none, // <--- WALANG BORDER
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          item['question']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Text(
                              item['answer']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                        iconColor: Colors.black54,
                        collapsedIconColor: Colors.black45,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
