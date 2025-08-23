import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/submission_model.dart';

class SubmissionViewModel extends ChangeNotifier {
  final List<Submission> _submissions = [
    Submission(
        id: '1',
        word: 'Eat',
        dialect: 'Legazpeño Bikol',
        date: DateTime(2025, 8, 12),
        status: 'Pending',
        translation: 'Kaon',
        phonetics: '/ˈkaɔn/',
        partOfSpeech: 'Verb',
        tagalog: 'Kain',
        definition: 'To put (food) into the mouth and chew and swallow dhfgjksa kjsdhgkjsah g asjdghfska dgjahsdg asdggkjhsad gsagjkh fgdkshfgjkhds dfjghd fgljkh sdfgjk sjfdghdsjkfg kljdhfgjsdh.',
        exampleSentence: 'Kaon na kita!',
        synonyms: 'Lugod, Pakaon',
        etymology: 'orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut eni'

    ),
    Submission(
        id: '2',
        word: 'Stop',
        dialect: 'West Miraya',
        date: DateTime(2025, 4, 12),
        status: 'Approved',
        translation: 'Pundo',
        phonetics: '/ˈPondo/',
        partOfSpeech: 'Verb',
        tagalog: 'Tigil',
        definition: 'To cease from some action or operation; to come to an end.',
        exampleSentence: 'Pundo na kita!',
        synonyms: 'Para, Pakaon',
        etymology: 'orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut eni'
    ),
    Submission(
        id: '3',
        word: 'House',
        dialect: 'Legazpeño Bikol',
        date: DateTime(2025, 8, 12),
        status: 'Denied',
        translation: 'Harong',
        phonetics: '/haron/',
        partOfSpeech: 'Noun',
        tagalog: 'Bahay',
        definition: 'A building for human habitation, especially one that consists of a ground floor.',
        exampleSentence: 'Asin harong mo',
        synonyms: 'Balay, Tahanan',
        etymology: 'orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut eni'

    ),
    Submission(
        id: '4',
        word: 'Water',
        dialect: 'East Miraya',
        date: DateTime(2025, 8, 12),
        status: 'Flagged',
        translation: 'Tubig',
        phonetics: '/tubig/',
        partOfSpeech: 'Noun',
        tagalog: 'Tubig',
        definition: 'A colorless, transparent, odorless liquid that forms the seas, lakes, riversss.',
        exampleSentence: 'Mag inom ka tubig',
        synonyms: 'Lugod, Pakaon',
        etymology: 'orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut eni'

    ),
    Submission(
        id: '5',
        word: 'Love',
        dialect: 'Libon Bikol',
        date: DateTime(2025, 6, 12),
        status: 'Pending',
        translation: 'Gugma',
        phonetics: '/ˈgugma/',
        partOfSpeech: 'Noun',
        tagalog: 'Pagmamahal',
        definition: 'An intense feeling of deep affection.',
        exampleSentence: 'Gugma ko saimo.',
        synonyms: 'Lugod, Pakaon',
        etymology: 'orem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut eni'

    ),
  ];

  List<Submission> get submissions => _submissions;

  Submission? getSubmissionById(String id) {
    try {
      return _submissions.firstWhere((submission) => submission.id == id);
    } catch (e) {
      return null;
    }
  }
}
