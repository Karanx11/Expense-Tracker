import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  final formKey = GlobalKey<FormState>();

  Future signup() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await ApiService.signup(
      nameController.text.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (result["message"] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(email: emailController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Signup failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Form(
          key: formKey,

          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter name";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                validator: (value) {
                  if (value == null || value.length < 10) {
                    return "Enter valid phone";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              const SizedBox(height: 15),

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

              const SizedBox(height: 15),

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
                      hidePassword ? Icons.visibility : Icons.visibility_off,
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

              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: signup,
                      child: const Text("Send OTP"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
