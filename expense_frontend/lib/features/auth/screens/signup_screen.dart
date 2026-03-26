import 'dart:ui';
import 'package:expense_frontend/shared/services/api_service.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_textfield.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1A5276)],
              ),
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      AuthTextField(hint: "Email", controller: emailController),

                      const SizedBox(height: 15),

                      AuthTextField(
                        hint: "Password",
                        isPassword: true,
                        controller: passwordController,
                      ),

                      const SizedBox(height: 20),

                      AuthButton(
                        text: "Signup",
                        onPressed: () async {
                          final res = await ApiService().signup(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res["msg"] ?? "")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
