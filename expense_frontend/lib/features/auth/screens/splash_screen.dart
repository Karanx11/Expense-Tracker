import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color primaryColor = const Color(0xFF606F49);

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await ApiService().getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void goNext() async {
    final token = await ApiService().getToken();

    if (!mounted) return;

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
          /// 🌌 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ✨ FLOATING DOTS
          const Positioned.fill(child: FloatingDots()),

          /// 🧊 MAIN CONTENT
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🟢 LOGO (GLASS EFFECT)
                ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(18), // ↓ reduced padding
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 150,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🏷️ TITLE
                const Text(
                  "Expense Tracker",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 10),

                /// 📝 SUBTITLE
                const Text(
                  "Manage your money smarter\nwith a premium experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 50),

                /// 🚀 BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: goNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
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

/// ✨ FLOATING DOTS
class FloatingDots extends StatefulWidget {
  const FloatingDots({super.key});

  @override
  State<FloatingDots> createState() => _FloatingDotsState();
}

class _FloatingDotsState extends State<FloatingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final List<Offset> dots = List.generate(
    15,
    (index) => Offset(Random().nextDouble(), Random().nextDouble()),
  );

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(painter: DotPainter(dots, controller.value));
      },
    );
  }
}

class DotPainter extends CustomPainter {
  final List<Offset> dots;
  final double animationValue;

  DotPainter(this.dots, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);

    for (var dot in dots) {
      final dx = dot.dx * size.width;
      final dy = (dot.dy * size.height + animationValue * 50) % size.height;

      canvas.drawCircle(Offset(dx, dy), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
