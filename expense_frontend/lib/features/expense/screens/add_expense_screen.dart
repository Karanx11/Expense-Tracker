import 'package:expense_frontend/core/utils/notification_service.dart';
import 'package:expense_frontend/shared/services/api_service.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

  bool isLoading = false;

  final List<String> categories = [
    "Food",
    "Travel",
    "Shopping",
    "Bills",
    "Other",
  ];

  /// 📅 Pick Date
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  /// 💸 Add Expense
  Future<void> addExpense() async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter amount")));
      return;
    }

    final amount = double.tryParse(amountController.text);

    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid amount")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await ApiService().postExpense({
        "amount": amount,
        "category": selectedCategory,
        "note": noteController.text,
        "date": selectedDate.toIso8601String(),
      });

      if (res["expense"] != null) {
        double remaining = (res["remaining"] ?? 0).toDouble();

        /// 🔔 SIMPLE NOTIFICATION (FINAL)
        await NotificationService.show(
          "Budget Update 💰",
          "₹$remaining left this month",
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Expense Added")));

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["msg"] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 💰 Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// 📝 Note
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: "Note",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// 📂 Category
            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => selectedCategory = val.toString()),
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            /// 📅 Date Picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                  ),
                ),
                TextButton(onPressed: pickDate, child: const Text("Pick Date")),
              ],
            ),
            const SizedBox(height: 20),

            /// 🚀 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : addExpense,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
