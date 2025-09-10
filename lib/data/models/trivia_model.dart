import 'package:cloud_firestore/cloud_firestore.dart';

class TriviaModel {
  final String id;
  final String sentence;
  final DateTime dateAdded;

  TriviaModel({
    required this.id,
    required this.sentence,
    required this.dateAdded,
  });

  factory TriviaModel.fromFirestore(Map<String, dynamic> json, String id) {
    return TriviaModel(
     id: id,
      sentence: json['sentence'] ?? '',
      dateAdded: (json['date_added'] as Timestamp).toDate(),
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'date_added': dateAdded,
    };
  }


}
