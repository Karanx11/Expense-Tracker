import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String category = "Food";
  DateTime selectedDate = DateTime.now();

  bool loading = false;

  List categories = ["Food", "Travel", "Shopping", "Bills", "Others"];

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> addExpense() async {
    setState(() {
      loading = true;
    });

    final res = await ApiService.addExpense(
      titleController.text,
      double.parse(amountController.text),
      category,
      noteController.text,
      selectedDate.toIso8601String(),
    );

    setState(() {
      loading = false;
    });

    String? warning = res["warning"];

    if (warning == "WARNING_LIMIT") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠ You have used 80% of your monthly limit"),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (warning == "CRITICAL_LIMIT") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 You are close to exceeding your limit!"),
          backgroundColor: Colors.red,
        ),
      );
    } else if (warning == "LIMIT_EXCEEDED") {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Limit Exceeded"),
          content: const Text("You are exceeding your monthly spending limit."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Add Expense"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField(
              initialValue: category,
              dropdownColor: Colors.black,
              items: categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value as String;
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),

            const SizedBox(height: 15),

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

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addExpense,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Add Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
