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

  final Color primaryColor = const Color(0xFF606F49);

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryColor,
              surface: const Color(0xFF121212),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

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

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Add Expense"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 💰 Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration("Amount"),
            ),
            const SizedBox(height: 16),

            /// 📝 Note
            TextField(
              controller: noteController,
              style: const TextStyle(color: Colors.white),
              decoration: inputDecoration("Note"),
            ),
            const SizedBox(height: 16),

            /// 📂 Category
            DropdownButtonFormField(
              dropdownColor: const Color(0xFF1E1E1E),
              value: selectedCategory,
              style: const TextStyle(color: Colors.white),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => selectedCategory = val.toString()),
              decoration: inputDecoration("Category"),
            ),
            const SizedBox(height: 16),

            /// 📅 Date Picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: pickDate,
                    child: Text("Pick", style: TextStyle(color: primaryColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// 🚀 Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isLoading ? null : addExpense,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Expense", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
