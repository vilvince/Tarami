import 'package:flutter/material.dart';
import '../data/user_model.dart';

class UserVM extends ChangeNotifier {
  final List<UserModel> users = [
    UserModel(
      name: "Juan Dela Cruz",
      email: "juan@email.com",
      contactNumber: "09171234567",
      submittedWords: 5,
      role: "User",
    ),
    UserModel(
      name: "Admin User",
      email: "admin@email.com",
      contactNumber: "09101065534",
      submittedWords: 12,
      role: "Admin",
    ),
  ];

  void addUser(UserModel user) {
    users.add(user);
    notifyListeners();
  }

  void updateUserRole(UserModel user, String newRole) {
    user.role = newRole;
    notifyListeners();
  }

  void deleteUser(UserModel user) {
    users.remove(user);
    notifyListeners();
  }
}
