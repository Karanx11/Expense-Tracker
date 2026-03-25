import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';

class MonthlyLimitScreen extends StatefulWidget {
  const MonthlyLimitScreen({super.key});

  @override
  State<MonthlyLimitScreen> createState() => _MonthlyLimitScreenState();
}

class _MonthlyLimitScreenState extends State<MonthlyLimitScreen> {
  final limitController = TextEditingController();

  Future<void> setLimit() async {
    final res = await ApiService().setLimit({
      "limit": double.parse(limitController.text),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["limit"] != null ? "Limit Set" : "Error")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1A5276)],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Text(
                        "Set Monthly Limit",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _glassContainer(
                    child: Column(
                      children: [
                        TextField(
                          controller: limitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Enter Monthly Budget",
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: setLimit,
                          child: const Text("Save Limit"),
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
          ),
          child: child,
        ),
      ),
    );
  }
}
