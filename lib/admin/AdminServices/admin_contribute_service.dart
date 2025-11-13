import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/contribute/data/contribute_model.dart'; // Adjust path

class AdminContributeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitDirectContribution(ContributeModel contribution) async {
    final word = contribution.word.trim();
    final dialectKey = _dialectNameToKey(contribution.dialect);
    final collection = _firestore.collection('dictionary');

    final existingWordQuery = await collection.where('word', isEqualTo: word).limit(1).get();

    // Create the new translation map from the form data
    final newTranslationMap = {
      'dialect': dialectKey,
      'translation': contribution.translation,
      'phonetics': contribution.phonetic,
      // ✅ FIX: Only store the DIALECT example in the translations array
      'sample_sentence': contribution.exampleSentenceInDialect,
    };

    if (existingWordQuery.docs.isNotEmpty) {
      // CASE 1: The word already exists.
      final wordDoc = existingWordQuery.docs.first;
      final wordData = wordDoc.data();
      final currentTranslations = List<Map<String, dynamic>>.from(wordData['translations'] ?? []);

      // Check if this specific dialect translation already exists.
      final index = currentTranslations.indexWhere((t) => t['dialect'] == dialectKey);

      if (index != -1) {
        // ✅ CASE 1A: WORD AND DIALECT EXIST (Update Everything)
        // The dialect is a duplicate, so we update it in the list
        currentTranslations[index] = newTranslationMap;

        // And update all the top-level fields
        await wordDoc.reference.update({
          'definition': contribution.definition,
          'part_of_speech': contribution.partOfSpeech,
          'tagalog': contribution.tagalogTranslation,
          'example_sentence': contribution.exampleSentenceInEnglish,
          'synonyms': _parseSynonyms(contribution.synonyms),
          'translations': currentTranslations,
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        // ✅ CASE 1B: WORD EXISTS, BUT DIALECT IS NEW (Add to array only)
        // Add the new dialect to the list
        currentTranslations.add(newTranslationMap);

        // ONLY update the translations array and the timestamp
        await wordDoc.reference.update({
          'translations': currentTranslations,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // CASE 2: The word is new. Create a new document.
      await collection.add({
        'word': word,
        'definition': contribution.definition,
        'part_of_speech': contribution.partOfSpeech,
        'tagalog': contribution.tagalogTranslation,
        'example_sentence': contribution.exampleSentenceInEnglish,
        'synonyms': _parseSynonyms(contribution.synonyms),
        'created_at': FieldValue.serverTimestamp(),
        'created_by': 'admin',
        'updated_at': FieldValue.serverTimestamp(),
        'translations': [newTranslationMap], // Add the first translation
      });
    }
  }

  // --- Helper Methods ---
  String _dialectNameToKey(String dialectName) {
    return dialectName.toLowerCase().trim().replaceAll(' ', '_');
  }

  List<String> _parseSynonyms(String? synonyms) {
    if (synonyms == null || synonyms.trim().isEmpty) return [];
    return synonyms.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}