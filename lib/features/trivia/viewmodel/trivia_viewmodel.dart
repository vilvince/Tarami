import 'package:flutter/material.dart';

class TriviaViewModel extends ChangeNotifier {
  final List<InlineSpan> triviaItems = [
    const TextSpan(
      children: [
        TextSpan(
          text: 'Central Bikol',
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' is widely spoken. Example words: '),
        TextSpan(
          text: '“Bahay”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means house, '),
        TextSpan(
          text: '“Kaon”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means eat, '),
        TextSpan(
          text: '“Salamat”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means thank you.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      children: [
        TextSpan(
          text: 'West Miraya',
          style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' is spoken in Daraga and Ligao. Example words: '),
        TextSpan(
          text: '“Lubi”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means coconut, '),
        TextSpan(
          text: '“Tubig”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means water, '),
        TextSpan(
          text: '“Balay”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means house.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      children: [
        TextSpan(
          text: 'East Miraya',
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' is spoken in eastern Albay. Examples: '),
        TextSpan(
          text: '“Kaipuhan”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means need, '),
        TextSpan(
          text: '“Hapít”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means near, '),
        TextSpan(
          text: '“Mangaon”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means will eat.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      children: [
        TextSpan(
          text: 'Libon Bikol',
          style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' is a minority dialect. Examples: '),
        TextSpan(
          text: '“Kusina”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means kitchen, '),
        TextSpan(
          text: '“Linao”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means clear, '),
        TextSpan(
          text: '“Agaw”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means take or grab.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      children: [
        TextSpan(
          text: 'Rinconada Bikol',
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' is spoken in parts of Camarines Sur. Examples: '),
        TextSpan(
          text: '“Tara”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means go, '),
        TextSpan(
          text: '“Saro”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means one, '),
        TextSpan(
          text: '“Harong”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means house.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      children: [
        TextSpan(
          text: 'Fun Facts',
          style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ': Some Bikol words are similar across dialects, while others are unique.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      children: [
        TextSpan(
          text: 'Additional Examples',
          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ':'),
        TextSpan(
          text: ' “Dai”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means no, '),
        TextSpan(
          text: '“Iyo”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means yours, '),
        TextSpan(
          text: '“Mayo”',
          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: ' means none.'),
      ],
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
    const TextSpan(
      text: 'Learning Bikol dialects preserves the language, culture, and identity of the region, helping future generations stay connected to their heritage.',
      style: TextStyle(color: Colors.white, fontSize: 15),
    ),
  ];
}
