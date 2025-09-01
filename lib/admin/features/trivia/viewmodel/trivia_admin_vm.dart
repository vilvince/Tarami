import 'package:flutter/material.dart';
import '../data/trivia_model.dart';

class TriviaAdminVM extends ChangeNotifier {
  final List<Trivia> _items = [
    Trivia(id: 't1', text: 'Mayon Volcano – Known for its near-perfect cone, it is the most active volcano in the Philippines.'),
    Trivia(id: 't2', text: 'The Cagsawa Ruins are remnants of the church tower destroyed by the 1814 eruption.'),
    Trivia(id: 't3', text: 'Albay is part of the Bicol Region (Region V) and is bordered by Sorsogon, Camarines Sur, and the Lagonoy Gulf.'),
  ];

  List<Trivia> get items => List.unmodifiable(_items);

  void addTrivia(String text) {
    _items.add(Trivia(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text.trim()));
    notifyListeners();
  }

  void updateTrivia(String id, String newText) {
    final i = _items.indexWhere((t) => t.id == id);
    if (i != -1) {
      _items[i].text = newText.trim();
      notifyListeners();
    }
  }

  void deleteTrivia(String id) {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
