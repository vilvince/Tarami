import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? errorMessage;
  bool emailSent = false;
  bool isLoading = false;

  Future<void> resetPassword(String email) async {
    errorMessage = null;
    emailSent = false;

    if (email.isEmpty) {
      errorMessage = "Email is required";
      notifyListeners();
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      emailSent = true; // ✅ Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Please enter a valid email address";
          break;
        case "user-not-found":
          errorMessage = "No account found with this email";
          break;
        default:
          errorMessage = "Something went wrong. Please try again.";
      }
    }
    notifyListeners();
  }
}
