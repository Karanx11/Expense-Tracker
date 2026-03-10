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
    loadExpenses();
  }

  void loadExpenses() async {
    try {
      final res = await ApiService.getExpenses();

      setState(() {
        expenses = res;
        loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void deleteExpense(String id) async {
    await ApiService.deleteExpense(id);

    loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Expense History")),

      body: ListView.builder(
        itemCount: expenses.length,

        itemBuilder: (context, index) {
          final exp = expenses[index];

          return ListTile(
            title: Text(exp["title"]),
            subtitle: Text(exp["category"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("₹${exp["amount"]}"),

                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteExpense(exp["_id"]);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
