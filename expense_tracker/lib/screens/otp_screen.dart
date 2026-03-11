import 'package:expense_tracker/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool fromForgotPassword;

  const OtpScreen({
    super.key,
    required this.email,
    this.fromForgotPassword = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool loading = false;

  String getOtp() {
    return controllers.map((c) => c.text).join();
  }

  Future verifyOtp() async {
    String otp = getOtp();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid OTP")));
      return;
    }

    setState(() => loading = true);

    final result = await ApiService.verifyOtp(widget.email, otp);

    setState(() => loading = false);

    if (result["message"] == "OTP verified") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP Verified")));

      /// FORGOT PASSWORD FLOW
      if (widget.fromForgotPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      }
      /// SIGNUP FLOW
      else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Invalid OTP")),
      );
    }
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 45,

      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,

        decoration: const InputDecoration(counterText: ""),

        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }

          if (value.isNotEmpty && index == 5) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              "Enter the OTP sent to your email",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => otpBox(index)),
            ),

            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyOtp,
                    child: const Text("Verify OTP"),
                  ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () async {
                await ApiService.sendOtp(widget.email);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("OTP resent")));
              },
              child: const Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
