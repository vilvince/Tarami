import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart'; // Ensure this import is correct
import 'package:tarami_application/features/auth/veiwmodel/forgot_password_view_model.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recommendation: Manage emailController in the ViewModel
    final emailController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.emailSent) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF0B1E2D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  content: Text(

                    textAlign: TextAlign.center,
                    // Recommendation: Use email from ViewModel (e.g., vm.lastUsedEmail)
                      "Password reset email sent to ${emailController.text.trim()}", style: TextStyle(color: Colors.white, fontSize: 20),),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        vm.emailSent = false;   // Reset state
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Ok", style: TextStyle(color: Colors.black, fontSize: 17)),
                    ),
                  ],
                ),
              );
              // vm.emailSent = false; // Reset after showing dialog - MOVED
            }
          });

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column( // Outer Column for Back Button and Content Area
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding( // Padding for the back button
                    padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded( // Content area takes remaining space
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0)
                          .copyWith(top: 20), // Reduced top padding a bit, adjust as needed
                      // --- FIX: Wrap inner Column with SingleChildScrollView ---
                      child: SingleChildScrollView(
                        child: Column(
                          // Removed crossAxisAlignment and mainAxisAlignment if not strictly needed,
                          // SingleChildScrollView will handle the size.
                          // You can add mainAxisAlignment: MainAxisAlignment.center
                          // if you want the content centered vertically when it doesn't overflow.
                          children: [
                            const SizedBox(height: 60), // Space from top or back button
                            const Text(
                              "Forgot Password?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Don’t worry, it happens!\nPlease enter email associated with your account.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 32),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Email", style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: emailController, // Link to ViewModel's controller
                              cursorColor: Colors.black,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 14,
                                ),
                                errorText: vm.errorMessage,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC845),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  onPressed: () {
                                    vm.resetPassword(emailController.text.trim());
                                },
                                  child: const Text(
                                    "Send Reset Link",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20), // Add some padding at the bottom for scrolling
                          ],
                        ),
                      ),
                      // --- END OF FIX ---
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

