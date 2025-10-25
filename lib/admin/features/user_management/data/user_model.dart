import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  String? contactNumber;
  int submittedWords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.contactNumber,
    this.submittedWords = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Full name getter
  String get fullName => '$firstName $lastName';

  // Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contact_number'],
      submittedWords: data['submitted_words'] ?? 0,
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : null,
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'contact_number': contactNumber,
      'submitted_words': submittedWords,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // For updating existing documents
  Map<String, dynamic> toUpdateMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'contact_number': contactNumber,
      'submitted_words': submittedWords,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? contactNumber,
    int? submittedWords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      submittedWords: submittedWords ?? this.submittedWords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}