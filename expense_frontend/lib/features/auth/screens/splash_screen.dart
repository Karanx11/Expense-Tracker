import 'dart:async';
import 'dart:ui';
import 'package:expense_frontend/features/auth/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color primaryColor = const Color(0xFF606F49);

  double progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  Future<void> startLoading() async {
    final token = await ApiService().getToken();

    /// 🔄 FAKE LOADING ANIMATION (SMOOTH)
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      setState(() {
        progress = i / 100;
      });
    }

    if (!mounted) return;

    /// 🔐 NAVIGATION
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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
      backgroundColor: const Color(0xFF0D0D0D),

      body: Stack(
        children: [
          /// 🌌 FULL BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1F17)],
              ),
            ),
          ),

          /// 💰 CENTER CONTENT (FULL SCREEN STYLE)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF606F49).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Color(0xFF606F49),
                ),
              ),

              const SizedBox(height: 20),

              /// APP NAME
              const Text(
                "Expense Tracker",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              /// TAGLINE
              const Text(
                "Smart Finance • Premium Experience",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),

          /// 📊 PROGRESS BAR (BOTTOM)
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF606F49)),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          /// 👨‍💻 FOOTER
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Built by Karan",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
