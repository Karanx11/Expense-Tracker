import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future checkLogin() async {
    await ApiService.loadToken();

    await Future.delayed(const Duration(seconds: 2));

    if (ApiService.token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: const [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Color(0xFF4F7C82),
            ),

            SizedBox(height: 20),

            Text(
              "Expense Tracker",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
