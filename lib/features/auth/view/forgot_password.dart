import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/auth/veiwmodel/forgot_password_view_model.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () {
                        if (vm.passwordChanged) {
                          vm.resetAll();
                        } else if (vm.showResetPassword) {
                          vm.showResetPassword = false;
                        } else if (vm.codeSent) {
                          vm.codeSent = false;
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: vm.passwordChanged
                          ? _PasswordChangedView()
                          : (vm.showResetPassword
                          ? _ResetPasswordView()
                          : (vm.codeSent
                          ? _CodeInputView()
                          : _EmailInputView())),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailInputView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context);
    return Column(
      children: [
        const SizedBox(height: 120),
        const Text(
          "Forgot Password?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Don’t worry It happens!\nPlease enter email associated with your account.",
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
          controller: vm.emailController,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC845),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            onPressed: vm.sendCode,
            child: const Text("Send Code",
                style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
      ],
    );
  }
}

class _CodeInputView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context);
    return Column(
      children: [
        const SizedBox(height: 100),
        const Text(
          "Please check your email",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          "We’ve sent a code to ${vm.emailController.text.isNotEmpty ? vm.emailController.text : "email@gmail.com"}",
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 60,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TextField(
                controller: vm.codeControllers[index],
                maxLength: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: "",
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC845),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: vm.verifyCode,
            child: const Text("Verify",
                style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
        const SizedBox(height: 12),
        const Text("Resend code  5:00", style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

class _ResetPasswordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 80),
        const Center(
          child: Column(
            children: [
              Text(
                "Reset Password",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Please type something you will\nremember",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text("New Password", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        TextField(
          obscureText: vm.obscureNewPassword,
          controller: vm.newPasswordController,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            errorText: vm.newPasswordError, // show validation error
            suffixIcon: IconButton(
              icon: Icon(vm.obscureNewPassword
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: vm.toggleObscureNewPassword,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        const Text("Confirm Password", style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        TextField(
          obscureText: vm.obscureConfirmPassword,
          controller: vm.confirmPasswordController,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            errorText: vm.confirmPasswordError, // show validation error
            suffixIcon: IconButton(
              icon: Icon(vm.obscureConfirmPassword
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: vm.toggleObscureConfirmPassword,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC845),
              padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: vm.resetPassword,
            child: const Text("Reset Password",
                style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
      ],
    );
  }
}

class _PasswordChangedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 100,
          backgroundColor: Colors.black12,
        ),
        const SizedBox(height: 32),
        const Text(
          "Password Changed!",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          "Your Password has been changed\nsuccessfully!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC845),
            padding:
            const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            vm.resetAll();
          },
          child: const Text("Reset Password",
              style: TextStyle(fontSize: 18, color: Colors.black)),
        ),
      ],
    );
  }
}
