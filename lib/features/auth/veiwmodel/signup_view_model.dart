import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Errors
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  // Obscure text states
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Terms agreement
  bool agreeToTerms = false;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  // Set agreement to terms
  void setAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners();
  }

  // Show Terms and Conditions dialog with full text
  void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Terms and Conditions"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: const Text(
                "Welcome to Tarami, a digital dictionary that offers translations into English and Tagalog with the goal of conserving and promoting Albay's local dialects. By using our app, you agree to the following Terms and Conditions.\n\n"
                    "1. Acceptance of the Terms\n"
                    "You accept these terms and conditions by using Tarami or by accessing it. You are required to stop using the app if you disagree with any of these terms.\n\n"
                    "2. Contributions from Users\n"
                    "- New terms and translations can be added to the dictionary by users.\n"
                    "- Before publication, all submissions will go through a review and approval process by professional linguists.\n"
                    "- Users are required to make sure their contributions are truthful and considerate.\n"
                    "- Content that is offensive, improper, or deceptive will be deleted.\n"
                    "- Tarami retains the right, at its sole discretion, to edit, change, or reject any submission.\n\n"
                    "3. Intellectual Property\n"
                    "All content, including translations, definitions, and linguistic resources, is the property of Tarami and its licensors. By submitting content, you grant Tarami a non-exclusive, royalty-free, worldwide license to use, distribute, and modify your contribution for educational and promotional purposes. Users must not copy, reproduce, or distribute content from Tarami without explicit permission.\n\n"
                    "4. Limitations and Accuracy\n"
                    "Tarami makes every effort to ensure linguistic accuracy, however we cannot guarantee that all definitions and translations are flawless. The app should not be used in place of expert language consultation when necessary; rather, it is meant to serve as a reference tool.\n\n"
                    "5. User Responsibilities\n"
                    "Users must not misuse the platform by submitting false, offensive, or plagiarized content. Users must not attempt to interfere with the app’s functionality, including hacking, spamming, or any unauthorized access. Users are responsible for ensuring that their contributions do not violate copyright laws or intellectual property rights. Users who repeatedly submit inappropriate content may be restricted or banned from using contribution features.\n\n"
                    "6. Privacy Policy\n"
                    "By using Tarami, you also agree to our Privacy Policy, which explains how we collect, use, and protect your personal data.\n\n"
                    "7. Modifications to Terms\n"
                    "Tarami reserves the right to update or modify these Terms and Conditions at any time. Continued use of the app after changes are made constitutes acceptance of the revised terms."
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setAgreeToTerms(true);
              Navigator.of(context).pop();
            },
            child: const Text("Agree"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Validate form
  bool validate() {
    bool isValid = true;

    // Reset previous errors
    emailError = null;
    passwordError = null;
    confirmPasswordError = null;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      emailError = 'Please enter a valid email';
      isValid = false;
    }

    // Password validation: minimum 8 characters, at least one letter, one number, one special character
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&^_-])[A-Za-z\d@$!%*#?&^_-]{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      passwordError = 'Password must be at least 8 characters\nand include letters, numbers, and special characters';
      isValid = false;
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match';
      isValid = false;
    }

    if (!agreeToTerms) {
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }
}
