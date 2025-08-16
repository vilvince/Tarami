import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> codeControllers =
  List.generate(4, (_) => TextEditingController());

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? newPasswordError;
  String? confirmPasswordError;

  bool codeSent = false;
  bool showResetPassword = false;
  bool passwordChanged = false;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  void toggleObscureNewPassword() {
    obscureNewPassword = !obscureNewPassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void sendCode() {
    codeSent = true;
    notifyListeners();
  }

  void verifyCode() {
    showResetPassword = true;
    notifyListeners();
  }

  bool _isValidPassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void resetPassword() {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate new password
    if (newPassword.isEmpty) {
      newPasswordError = "Please enter your new password";
    } else if (!_isValidPassword(newPassword)) {
      newPasswordError =
      "Password must be at least 8 characters\nwith letters, numbers, and special characters";
    } else {
      newPasswordError = null;
    }

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Please confirm your password";
    } else if (confirmPassword != newPassword) {
      confirmPasswordError = "Passwords do not match";
    } else {
      confirmPasswordError = null;
    }

    notifyListeners();

    // If both are valid
    if (newPasswordError == null && confirmPasswordError == null) {
      passwordChanged = true;
      notifyListeners();
    }
  }

  void resetAll() {
    codeSent = false;
    showResetPassword = false;
    passwordChanged = false;

    emailController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    for (var c in codeControllers) {
      c.clear();
    }
    obscureNewPassword = true;
    obscureConfirmPassword = true;
    newPasswordError = null;
    confirmPasswordError = null;

    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    for (var c in codeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void handleBackButton() {}
}
