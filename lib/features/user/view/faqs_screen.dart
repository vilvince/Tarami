import 'package:flutter/material.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is Tarami?',
      'answer':
      'Tarami is a mobile dictionary application designed to provide translations, definitions, trivias, and commonly used phrases from the Albay region. It serves as a quick reference tool for users who want to learn or understand the Bikol language spoken in Albay.'
    },
    {
      'question': 'Does Tarami work offline?',
      'answer': 'Yes. The core dictionary features, word search, definitions, and basic browsing, can be accessed offline once the app is installed. This allows users to use the app even without internet connection.'
    },
    {
      'question': 'When do I need an internet connection?',
      'answer':
      'An internet connection is required for the following features:\n'
      'Logging in or creating an account.\n'
      'Contributing new words.\n'
      'Playing in-app games.\n'
      'Refreshing and downloading newly added words from the server.'
    },
    {
      'question': 'Is Tarami free to use?',
      'answer': 'Yes. All major features of Tarami are free. Users can access the dictionary, contribute words, and play games without any subscription.'
    },
    {
      'question': 'How do I search for words in Tarami?',
      'answer': 'Simply type a word into the search bar. The app will display its meaning, translation, pronunciation (if available), and example usage.'
    },
    {
      'question': 'Can users submit or contribute new words?',
      'answer': 'Yes. Tarami includes a Word Contribution feature. Users can suggest new entries or corrections, but this requires an online connection so the suggestion can be uploaded to the system.'
    },
    {
      'question': 'Are the translations in Tarami verified?',
      'answer': 'Yes. Dictionary entries are based on credible sources and consultations with native speakers. However, since Bikol-Albay has dialect variations, some words may have multiple meanings depending on the locality.'
    },
    {
      'question': 'Does Tarami include pronunciation guides?',
      'answer': 'Yes. Selected words have pronunciation guides to help users practice correct pronunciation.'
    },
    {
      'question': ' Can I use Tarami for academic or research purposes?',
      'answer': 'Absolutely. Tarami can serve as a reference tool for students, teachers, and researchers focusing on the Albay variant of the Bikol language.'
    },
    {
      'question': 'Will Tarami receive updates?',
      'answer': 'Yes. The developers will release periodic updates to add new words, improve app features, enhance gameplay, and address user feedback.'
    },
    {
      'question': 'Who is Tarami designed for?',
      'answer': 'Tarami is intended for students, locals, tourists, educators, and anyone interested in learning or understanding the Albay Bikol language.'
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
