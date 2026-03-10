import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  bool loading = false;

  Future<void> sendOtp() async {
    setState(() {
      loading = true;
    });

    final res = await ApiService.forgotPassword(emailController.text);

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res["message"])));

    if (res["message"] == "OTP sent to email") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: emailController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : sendOtp,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
