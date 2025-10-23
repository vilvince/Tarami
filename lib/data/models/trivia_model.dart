import 'package:cloud_firestore/cloud_firestore.dart';

class TriviaModel {
  final String id;
  final String text;
  final DateTime created_at;

  TriviaModel({
    required this.id,
    required this.text,
    required this.created_at,
  });

  factory TriviaModel.fromFirestore(Map<String, dynamic> json, String id) {
    return TriviaModel(
     id: id,
      text: json['text'] ?? '',
      created_at: (json['created_at'] as Timestamp).toDate(),
    );

  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'text': created_at,
    };
  }


}
