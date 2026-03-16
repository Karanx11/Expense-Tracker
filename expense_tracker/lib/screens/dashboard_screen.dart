import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/transaction_card.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double monthlyBudget = 10000;
  DateTime lastResetDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    checkMonthlyReset();
  }

  /// RESET EXPENSES EVERY NEW MONTH
  void checkMonthlyReset() {
    DateTime now = DateTime.now();

    if (now.month != lastResetDate.month || now.year != lastResetDate.year) {
      lastResetDate = now;

      /// clear expenses for new month
      ExpenseService.expenses.clear();

      setState(() {});
    }
  }

  /// SET BUDGET DIALOG
  void showSetBudgetDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text("Set Monthly Budget"),

          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              hintText: "Enter amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  monthlyBudget =
                      double.tryParse(controller.text) ?? monthlyBudget;
                });

                Navigator.pop(context);
              },

              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    checkMonthlyReset();

    final List<Expense> expenses = ExpenseService.getExpenses();

    double totalSpent = 0;

    for (var expense in expenses) {
      totalSpent += expense.amount;
    }

    double remaining = monthlyBudget - totalSpent;

    double progress = totalSpent / monthlyBudget;

    if (progress > 1) {
      progress = 1;
    }

    return Scaffold(
      /// + BUTTON ABOVE NAVBAR
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),

        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            );

            setState(() {});
          },

          child: const Icon(Icons.add),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Container(
        padding: const EdgeInsets.all(20),

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1115), Color(0xFF1A1C22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Dashboard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                /// MONTHLY BUDGET CARD
                GlassCard(
                  height: 120,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Monthly Budget",
                            style: TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "₹$monthlyBudget",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Icon(Icons.account_balance_wallet, size: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// BUDGET PROGRESS
                GlassCard(
                  height: 190,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Budget Usage",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),

                        color: progress < 0.5
                            ? Colors.green
                            : progress < 0.8
                            ? Colors.orange
                            : Colors.red,

                        backgroundColor: Colors.white24,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Spent ₹$totalSpent of ₹$monthlyBudget",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(
                          onPressed: () {
                            showSetBudgetDialog(context);
                          },

                          icon: const Icon(Icons.edit),
                          label: const Text("Set Budget Limit"),

                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// SPENT & REMAINING CARDS
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        height: 120,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(Icons.trending_down),

                            const SizedBox(height: 10),

                            const Text("Spent"),

                            Text(
                              "₹$totalSpent",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: GlassCard(
                        height: 120,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(Icons.savings),

                            const SizedBox(height: 10),

                            const Text("Remaining"),

                            Text(
                              "₹$remaining",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                ...expenses.map((expense) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),

                    child: TransactionCard(
                      title: expense.note,
                      category: expense.category,
                      amount: "₹${expense.amount}",
                      date: expense.date.toString(),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
