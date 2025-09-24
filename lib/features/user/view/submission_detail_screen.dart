import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmissionDetailScreen extends StatelessWidget {
  final Map<String, String> submission;

  const SubmissionDetailScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d2334), // Dark background for the whole screen
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your Custom Back Button
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
              child: IconButton(
                color: Colors.white,
                iconSize: 28,
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 60),
            // This Expanded widget will ensure its child takes up remaining vertical space
            Expanded(
              child: Container(
                decoration: const BoxDecoration( // Outer container that will be white and expand with a top a curve
                  color: const Color(0xFFF3F2F2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView( // Scroll view for the content
                  // Padding for the content *within* the white area
                  padding: const EdgeInsets.fromLTRB(25, 45, 40, 20), // Added top padding back
                  child: Container( // This is your original content "card"
                    // This container might not even need its own background color anymore
                    // if the parent provides the white. Or it can have a slightly different shade
                    // or elevation for a card effect.
                    // For now, let's assume it's just for padding and logical grouping.
                    //padding: const EdgeInsets.all(10),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Make column only as tall as its content
                      children: [
                        // Word & Date
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                   Text(
                                    'Word:',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    submission['word'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Submitted:',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    submission['date'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ),

                        const SizedBox(height: 40),
                        buildDetailRow('Status:', submission['status']),
                        buildDetailRow('Tagalog:', submission['tagalog']),
                        buildDetailRow('Translation:', submission['translation']),
                        buildDetailRow('Dialect:', submission['dialect']),
                        buildDetailRow('Phonetic:', submission['phonetic']),
                        buildDetailRow('Part of Speech:', submission['partOfSpeech']),
                        buildDetailRow('Definition:', submission['definition']),
                        buildDetailRow('Example Sentence:', submission['exampleSentence']),
                        buildDetailRow('Synonyms:', submission['synonyms']),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String? value) {
    // ... (buildDetailRow remains the same) ...
    Color valueColor = Colors.black;
    if (label == 'Status:') {
      switch (value?. toLowerCase()) {
        case 'approved':
          valueColor = Colors.green;
          break;
        case 'pending':
          valueColor = Colors.orange;
          break;
        case 'denied':
          valueColor = Colors.red;
          break;
        case 'flagged':
          valueColor = Colors.purple;
          break;
        default:
          valueColor = Colors.black;
      }
    }


    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              value ?? '',
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: label == 'Status:' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
