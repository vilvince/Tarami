import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/trivia_model.dart';
import 'package:tarami_application/core/services//trivia_service.dart';


class TriviaViewModel extends ChangeNotifier {
  final TriviaService _service = TriviaService();
  List<TriviaModel> triviaList = [];
  bool isLoading = true;

  TriviaViewModel() {
    fetchTrivia();
  }

  void fetchTrivia() {
    _service.getTrivia().listen((data) {
      triviaList = data;
      isLoading = false;
      notifyListeners();
    });
  }
}
