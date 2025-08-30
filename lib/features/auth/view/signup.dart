import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/widgets/main_scaffold.dart';
import 'package:tarami_application/features/auth/veiwmodel/signup_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Consumer<SignUpViewModel>(
        builder: (context, vm, child) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/TaramiLogo.png',
                                  height: 250,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Transform.translate(
                                  offset: const Offset(0, -72),
                                  child: const Text(
                                    "Create your account.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 0.01,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Email Address"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: vm.emailController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    errorText: vm.emailError,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text("Password"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: vm.passwordController,
                                  obscureText: vm.obscurePassword,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        vm.obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: vm.togglePasswordVisibility,
                                    ),
                                    errorText: vm.passwordError,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text("Confirm Password"),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: vm.confirmPasswordController,
                                  obscureText: vm.obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        vm.obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: vm.toggleConfirmPasswordVisibility,
                                    ),
                                    errorText: vm.confirmPasswordError,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Checkbox(
                                      value: vm.agreeToTerms,
                                      onChanged: (value) {
                                        if (value == true) {
                                          vm.showTermsDialog(context);
                                        } else {
                                          vm.setAgreeToTerms(false);
                                        }
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () => vm.showTermsDialog(context),
                                      child: const Text(
                                        "I agree to the Terms & Conditions",
                                        style: TextStyle(
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: SizedBox(
                                    width: 250,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFC845),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                      ),
                                      onPressed: vm.isLoading ? null : () async {
                                        final user = await vm.signUp(context);
                                        if (user != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              const MainScaffold(),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        "Sign Up",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}