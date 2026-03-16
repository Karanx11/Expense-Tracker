import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  double monthlyBudget = 10000;

  void addExpense() {
    double amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      return;
    }

    final expense = Expense(
      amount: amount,
      category: categoryController.text,
      note: noteController.text,
      date: DateTime.now(),
      id: '',
    );

    ExpenseService.addExpense(expense);

    double totalSpent = 0;

    for (var e in ExpenseService.getExpenses()) {
      totalSpent += e.amount;
    }

    double remaining = monthlyBudget - totalSpent;

    /// Notifications
    if (remaining <= 0) {
      NotificationService.showNotification(
        "Budget Limit Exceeded",
        "You have exceeded your monthly budget!",
      );
    } else {
      NotificationService.showNotification(
        "Expense Added",
        "Remaining Budget: ₹$remaining",
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            /// AMOUNT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// CATEGORY
            TextField(
              controller: categoryController,

              decoration: InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// NOTE
            TextField(
              controller: noteController,

              decoration: InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: addExpense,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),

                child: const Text("Add Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
