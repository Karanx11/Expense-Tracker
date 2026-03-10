import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map data = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  void loadDashboard() async {
    try {
      final res = await ApiService.getDashboard();

      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Balance: ₹${data["balance"] ?? 0}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text("Total Expenses: ₹${data["totalExpenses"] ?? 0}"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await ApiService.addCash(500);

                loadDashboard();
              },
              child: const Text("Add ₹500 Cash"),
            ),
          ],
        ),
      ),
    );
  }
}
