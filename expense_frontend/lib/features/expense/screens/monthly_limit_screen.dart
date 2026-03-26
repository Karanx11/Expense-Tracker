import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';

class MonthlyLimitScreen extends StatefulWidget {
  const MonthlyLimitScreen({super.key});

  @override
  State<MonthlyLimitScreen> createState() => _MonthlyLimitScreenState();
}

class _MonthlyLimitScreenState extends State<MonthlyLimitScreen> {
  final TextEditingController limitController = TextEditingController();

  final Color primaryColor = const Color(0xFF606F49);

  Future<void> setLimit() async {
    if (limitController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a limit")));
      return;
    }

    final value = double.tryParse(limitController.text);

    if (value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid number")));
      return;
    }

    final res = await ApiService().setLimit({"limit": value});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["limit"] != null ? "Limit Updated" : "Error")),
    );

    Navigator.pop(context, true);
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      body: Stack(
        children: [
          /// 🌌 PREMIUM BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1F17)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔙 HEADER
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Set Monthly Budget",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// 💎 GLASS CARD
                  _glassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Monthly Limit",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        const SizedBox(height: 10),

                        /// 💰 INPUT
                        TextField(
                          controller: limitController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration(
                            "Enter your monthly budget",
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// 🚀 BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: setLimit,
                            child: const Text(
                              "Save Limit",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💎 GLASS CONTAINER
  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
