import 'package:flutter/material.dart';
import '../data/home_model.dart';

class HomeVM extends ChangeNotifier {
  HomeStats stats = HomeStats(
    approved: 2,
    denied: 2,
    read: 2,
    flagged: 2,
  );

  List<CommonWord> commonWords = [
    CommonWord(word: "Thanks", count: 51),
    CommonWord(word: "Beautiful", count: 30),
    CommonWord(word: "Love", count: 100),
    CommonWord(word: "Night", count: 15),
    CommonWord(word: "Face", count: 39),
    CommonWord(word: "Rain", count: 69),
  ];

  List<TopContributor> contributors = [
    TopContributor(name: "Jane Doe", words: 65),
    TopContributor(name: "John Smith", words: 60),
    TopContributor(name: "Mary Jane", words: 55),
    TopContributor(name: "Carlos Cruz", words: 50),
    TopContributor(name: "Anna Lee", words: 45),
  ];
}
