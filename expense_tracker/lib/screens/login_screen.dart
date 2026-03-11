import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  final formKey = GlobalKey<FormState>();

  Future login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (result["token"] != null) {
      /// SAVE TOKEN
      await ApiService.saveToken(result["token"]);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                const Text(
                  "Expense Tracker",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      children: [
                        /// EMAIL
                        TextFormField(
                          controller: emailController,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter email";
                            }
                            return null;
                          },

                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD
                        TextFormField(
                          controller: passwordController,
                          obscureText: hidePassword,

                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "Password must be 6 characters";
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),

                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// LOGIN BUTTON
                        loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: login,
                                child: const Text("Login"),
                              ),

                        const SizedBox(height: 10),

                        /// FORGOT PASSWORD
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text("Forgot Password?"),
                        ),

                        /// SIGNUP
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text("Create Account"),
                        ),
                      ],
                    ),
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
