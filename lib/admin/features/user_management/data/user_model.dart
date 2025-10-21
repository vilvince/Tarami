class UserModel {
  final String name;
  final String email;
  String? contactNumber;
  int submittedWords;
  String role;

  UserModel({
    required this.name,
    required this.email,
    this.contactNumber,
    this.submittedWords = 0,
    this.role = "User",
  });
}
