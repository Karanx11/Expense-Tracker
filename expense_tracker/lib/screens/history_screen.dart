import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

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

  /// GROUP EXPENSES BY MONTH
  Map<String, List<Expense>> groupByMonth(List<Expense> expenses) {
    Map<String, List<Expense>> grouped = {};

    for (var expense in expenses) {
      String key = DateFormat("MMMM yyyy").format(expense.date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(expense);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = groupByMonth(widget.expenses);

    return Scaffold(
      appBar: AppBar(title: const Text("Expense History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : widget.expenses.isEmpty
              ? const Center(
                  child:
                      Text("No expenses yet", style: TextStyle(fontSize: 18)),
                )
              : ListView(
                  children: groupedExpenses.entries.map((entry) {
                    String month = entry.key;
                    List<Expense> expenses = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// MONTH HEADER
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            month,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        /// EXPENSE LIST
                        ...expenses.map((e) {
                          int index = widget.expenses.indexOf(e);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: Icon(
                                e.paymentType == "Cash"
                                    ? Icons.money
                                    : Icons.credit_card,
                                color: const Color(0xFF4F7C82),
                              ),

                              title: Text(e.category),

                              /// NOTE + DATE TIME
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.note),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      "dd MMM yyyy • HH:mm",
                                    ).format(e.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "₹${e.amount}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => confirmDelete(e.id, index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
    );
  }
}
