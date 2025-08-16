import 'package:flutter/material.dart';
import 'package:tarami_application/widgets/main_scaffold.dart';

class LoginViewModel extends ChangeNotifier {
  bool obscurePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  // Registered credentials (hardcoded for now)
  final String registeredEmail = "example@gmail.com";
  final String registeredPassword = "pass@123"; // Example 8-char password

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void validateAndLogin(BuildContext context) {
    String email = emailController.text.trim();
    String password = passwordController.text;

    // Email validation
    if (email.isEmpty) {
      emailError = "Please enter your registered email";
    } else if (email != registeredEmail) {
      emailError = "This email is not registered";
    } else {
      emailError = null;
    }

    // Password validation
    if (password.isEmpty) {
      passwordError = "Please enter your 8 character password";
    } else if (password.length != 8 || password != registeredPassword) {
      passwordError = "Incorrect password";
    } else {
      passwordError = null;
    }

    notifyListeners();

    // If no errors, navigate to main page
    if (emailError == null && passwordError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScaffold()),
      );
    }
  }
}
