import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/core/services/auth_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;
  bool _isLoading = false;

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  final AuthService _authService = AuthService();

  bool get isLoading => _isLoading;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void setAgreeToTerms(bool value) {
    agreeToTerms = value;
    notifyListeners();
  }

  // Show Terms & Conditions
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

  // Handle Sign Up
  Future<User?> signUp(BuildContext context) async {
    if (_isLoading) return null;

    _isLoading = true;
    emailError = null;
    passwordError = null;
    confirmPasswordError = null;
    notifyListeners();

    // Validation
    if (emailController.text.isEmpty) {
      emailError = "Email is required";
    }

    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    // Password Strength Check
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

    if (password.isEmpty) {
      passwordError = "Password is required";
    } else if (!passwordRegex.hasMatch(password)) {
      passwordError = "Password must be at least 8 characters, include \nuppercase, lowercase, number, and \nspecial character";
    } else if (password.split('').every((char) => char == password[0])) {
      // Rejects if all characters are the same
      passwordError = "Password cannot be repetitive characters only";
    }
    if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError = "Passwords do not match";
    }
    if (!agreeToTerms) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to the Terms & Conditions")),
      );
      return null;
    }

    // If errors exist, stop
    if (emailError != null || passwordError != null || confirmPasswordError != null) {
      _isLoading = false;
      notifyListeners();
      return null;
    }

    try {
      // Call the AuthService to create the user
      await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Wait a moment for Firebase to fully process the user creation
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the current user directly from FirebaseAuth instance
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        _isLoading = false;
        notifyListeners();
        return user;
      } else {
        throw Exception("User creation failed - no user found");
      }

    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Try signing in instead.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = e.message ?? "Sign Up failed";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: e.code == 'email-already-in-use'
              ? SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () => Navigator.pop(context),
          )
              : null,
        ),
      );
      return null;

    } catch (e) {
      _isLoading = false;
      notifyListeners();

      // Even if there's a general exception, check if user was actually created
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User was created successfully despite the exception
        return user;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: ${e.toString()}")),
      );
      return null;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}