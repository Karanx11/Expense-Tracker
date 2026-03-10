import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List expenses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future fetchExpenses() async {
    try {
      final data = await ApiService.getExpenses();

      setState(() {
        expenses = data;
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteExpense(String id) async {
    await ApiService.deleteExpense(id);

    fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,

        itemBuilder: (context, index) {
          final exp = expenses[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.money, color: Colors.white),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp["title"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        exp["category"],
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Text(
                      "₹${exp["amount"]}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteExpense(exp["_id"]);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
