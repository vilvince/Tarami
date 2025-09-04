class Profile {
  final String firstName;
  final String lastName;
  final String gender;
  final String birthDate;
  final String contact;
  final String email;

  Profile({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthDate,
    required this.contact,
    required this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      contact: json['contact_number'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate,
      'contact_number': contact,
      'email': email,
    };
  }

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    String? birthDate,
    String? contact,
    String? email,
  }) {
    return Profile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      contact: contact ?? this.contact,
      email: email ?? this.email,
    );
  }
}