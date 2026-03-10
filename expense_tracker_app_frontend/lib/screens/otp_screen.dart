import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();

  bool loading = false;

  Future<void> verifyOtp() async {
    setState(() {
      loading = true;
    });

    final res = await ApiService.verifyOtp(widget.email, otpController.text);

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res["message"])));

    if (res["message"] == "Email verified successfully") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Text("Enter OTP sent to email"),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: "OTP"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : verifyOtp,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
