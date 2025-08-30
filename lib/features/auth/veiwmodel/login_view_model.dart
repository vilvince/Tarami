import 'package:flutter/material.dart';
import 'package:tarami_application/widgets/main_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/core/services/auth_service.dart';


class LoginViewModel extends ChangeNotifier {
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  // Use your AuthService instance
 final AuthService _authService = AuthService();

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> validateAndLogin(BuildContext context) async {
    print("=== LOGIN ATTEMPT STARTED ===");
    // Clear previous errors
    emailError = null;
    passwordError = null;

    String email = emailController.text.trim();
    String password = passwordController.text;

    print("Email: $email");
    print("Password length: ${password.length}");

    // Basic validation
    bool hasErrors = false;

    if (email.isEmpty) {
      emailError = "Please enter your email address";
      hasErrors = true;
    } else if (!_isValidEmail(email)) {
      emailError = "Please enter a valid email address";
      hasErrors = true;
    }

    if (password.isEmpty) {
      passwordError = "Please enter your password";
      hasErrors = true;
    }else if (!_isValidPassword(password)) {
      passwordError = "Incorrect password";
      hasErrors = true;
    }

    if (hasErrors) {
      print("Validation failed");
      notifyListeners();
      return;
    }

    print("Validation passed, starting Firebase login...");

    // Start loading
    isLoading = true;
    notifyListeners();

    try {
      // Use Firebase Auth to sign in
      await _authService.signIn(
        email: email,
        password: password,
      );


      print("Login successful via AuthService!");


      await Future.delayed(const Duration(milliseconds: 300));

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print("User confirmed logged in: ${currentUser.uid}");

        if (context.mounted) {
          print("Context is mounted, attempting navigation...");

          emailController.clear();
          passwordController.clear();

          // Method 1: Try pushAndRemoveUntil first
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScaffold()),
                (route) => false,
          );
        }
          print("Navigation  successful");
        } else {
        print("Login succeeded but user is null");
        emailError = "Login succeeded but session not established. Please try again.";
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      // Handle Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          emailError = "No account found with this email address";
          break;
        case 'wrong-password':
          passwordError = "Incorrect password";
          break;
        case 'invalid-email':
          emailError = "Invalid email address";
          break;
        case 'user-disabled':
          emailError = "This account has been disabled";
          break;
        case 'too-many-requests':
          passwordError = "Too many failed attempts. Please try again later";
          break;
        case 'invalid-credential':
          emailError = "Invalid email or password";
          break;
        default:
          emailError = "Login failed: ${e.message}";
      }
    } catch (e) {
      print("General Error: $e");
      // Handle other errors
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('type cast')) {
        print("Handling type casting error - checking auth state...");

        await Future.delayed(const Duration(milliseconds: 500));
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print("Login actually succeeded despite error! User: ${currentUser.uid}");

          if (context.mounted) {
            // Clear form
            emailController.clear();
            passwordController.clear();

            // Navigate to main page
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScaffold()),
                  (route) => false,
            );
            print("Navigation completed after error handling");
            return; // Exit successfully
          }
        }   
      }

      // If we reach here, it's a real error
      emailError = "Login failed. Please try again.";
    } finally {
      isLoading = false;
      notifyListeners();
      print("=== LOGIN ATTEMPT FINISHED ===");
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}