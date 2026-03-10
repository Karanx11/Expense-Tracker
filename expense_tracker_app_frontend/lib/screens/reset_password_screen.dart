import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> resetPassword() async {
    setState(() {
      loading = true;
    });

    final res = await ApiService.resetPassword(
      widget.email,
      otpController.text,
      passwordController.text,
    );

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res["message"])));

    if (res["message"] == "Password reset successful") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: "OTP"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : resetPassword,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
