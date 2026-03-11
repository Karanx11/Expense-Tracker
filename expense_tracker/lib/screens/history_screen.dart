import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final List<Expense> expenses;

  const HistoryScreen({super.key, required this.expenses});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool loading = false;

  /// DELETE EXPENSE
  Future deleteExpense(String id, int index) async {
    setState(() {
      loading = true;
    });

    try {
      await ApiService.deleteExpense(id);

      setState(() {
        widget.expenses.removeAt(index);
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Expense deleted")));
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Delete failed")));
    }
  }

  void confirmDelete(String id, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Expense"),

          content: const Text("Are you sure you want to delete this expense?"),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

              onPressed: () {
                Navigator.pop(context);
                deleteExpense(id, index);
              },

              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expense History")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : widget.expenses.isEmpty
          ? const Center(
              child: Text("No expenses yet", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: widget.expenses.length,

              itemBuilder: (context, index) {
                final e = widget.expenses[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  child: ListTile(
                    leading: Icon(
                      e.paymentType == "Cash" ? Icons.money : Icons.credit_card,
                      color: const Color(0xFF4F7C82),
                    ),

                    title: Text(e.category),

                    subtitle: Text(e.note),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${e.amount}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(e.id, index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
