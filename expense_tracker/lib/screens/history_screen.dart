import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../widgets/transaction_card.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Expense>>(
        future: ExpenseService.getExpenses(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No expenses found"));
          }

          final expenses = snapshot.data!;

          /// GROUP BY MONTH
          Map<String, List<Expense>> groupedByMonth = {};

          for (var expense in expenses) {
            String monthKey = DateFormat("MMMM yyyy").format(expense.date);

            groupedByMonth.putIfAbsent(monthKey, () => []);

            groupedByMonth[monthKey]!.add(expense);
          }

          return Container(
            padding: const EdgeInsets.all(20),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1115), Color(0xFF1A1C22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            child: SafeArea(
              child: ListView(
                children: [
                  const Text(
                    "Transaction History",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 25),

                  ...groupedByMonth.entries.map((monthEntry) {
                    /// GROUP BY DATE
                    Map<String, List<Expense>> groupedByDate = {};

                    for (var expense in monthEntry.value) {
                      String dateKey = DateFormat(
                        "dd MMM",
                      ).format(expense.date);

                      groupedByDate.putIfAbsent(dateKey, () => []);

                      groupedByDate[dateKey]!.add(expense);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        /// MONTH HEADER
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),

                          child: Text(
                            monthEntry.key,

                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        ...groupedByDate.entries.map((dateEntry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              /// DATE HEADER
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),

                                child: Text(
                                  dateEntry.key,

                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),

                              ...dateEntry.value.map((expense) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),

                                  child: Dismissible(
                                    key: Key(expense.id),

                                    direction: DismissDirection.endToStart,

                                    background: Container(
                                      alignment: Alignment.centerRight,

                                      padding: const EdgeInsets.only(right: 20),

                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),

                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),

                                    onDismissed: (direction) async {
                                      await ExpenseService.deleteExpense(
                                        expense.id,
                                      );

                                      setState(() {});

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Expense deleted"),
                                        ),
                                      );
                                    },

                                    child: TransactionCard(
                                      title: expense.note,
                                      category: expense.category,
                                      amount: "₹${expense.amount}",
                                      date: DateFormat(
                                        "HH:mm",
                                      ).format(expense.date),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
