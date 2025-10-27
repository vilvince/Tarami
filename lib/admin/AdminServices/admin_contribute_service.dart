import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/contribute/data/contribute_model.dart';

class AdminContributeService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Submit a word directly to the 'dictionary' collection.
  Future<void> submitDirectContribution(ContributeModel contribution) async {
    final word = contribution.word.trim();
    final dialectKey = _dialectNameToKey(contribution.dialect);
    final collection = _firestore.collection('dictionary');

    //Query to find if the word already exist
    final existingWordQuery = await collection.where('word', isEqualTo: word).limit(1).get();
// CASE 1: The word already exists. Update it.
    if (existingWordQuery.docs.isNotEmpty){
      final wordDoc = existingWordQuery.docs.first;
      final wordData = wordDoc.data();
      final currentTranslations = List<Map<String, dynamic>>.from(wordData['translations'] ?? []);

      // Check if this specific dialect translation already exists.
      final isDuplicate = currentTranslations.any((t) => t['dialect'] == dialectKey);
      if(isDuplicate){
        throw Exception('This dialect translation already exists for the word "$word".');
      }

      //Add the new dialect translation to the existing array.
      currentTranslations.add({
        'dialect': dialectKey,
        'translation': contribution.translation,
        'phonetics': contribution.phonetic,
        'sample_sentence': '${contribution.exampleSentenceInDialect}|${contribution.exampleSentenceInEnglish}',
      });

      //Update the document.
      await wordDoc.reference.update({
        'translations': currentTranslations,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }else{
      // CASE 2: The word is new. Create a new document.
      await collection.add({
        'word': word,
        'definition': contribution.definition,
        'part_of_speech': contribution.partOfSpeech,
        'tagalog': contribution.tagalogTranslation,
        'example_sentence': contribution.exampleSentenceInEnglish, // English example is top-level
        'synonyms': _parseSynonyms(contribution.synonyms),
        'created_at': FieldValue.serverTimestamp(),
        'created_by': 'admin',
        'updated_at': FieldValue.serverTimestamp(),
        'translations': [{
          'dialect': dialectKey,
          'translation': contribution.translation,
          'phonetics': contribution.phonetic,
          'sample_sentence': contribution.exampleSentenceInDialect, // Dialect example is nested
        }],
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