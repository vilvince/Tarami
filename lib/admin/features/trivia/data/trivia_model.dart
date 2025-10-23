import 'package:cloud_firestore/cloud_firestore.dart';

class Trivia {
  final String id;
  String text;
  final DateTime? createdAt;

  Trivia({
    required this.id,
    required this.text,
    this.createdAt,
  });

  /// Creates a Trivia instance from a Firestore document
  factory Trivia.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trivia(
      id: doc.id,
      text: data['text'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts Trivia to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}