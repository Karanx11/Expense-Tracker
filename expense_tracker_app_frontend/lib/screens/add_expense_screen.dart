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

  bool loading = false;

  void addExpense() async {
    try {
      setState(() {
        loading = true;
      });

      await ApiService.addExpense(
        titleController.text,
        double.parse(amountController.text),
        category,
        noteController.text,
        DateTime.now().toString(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Expense Added")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: category,
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
                DropdownMenuItem(value: "Travel", child: Text("Travel")),
                DropdownMenuItem(value: "Bills", child: Text("Bills")),
              ],
              onChanged: (val) {
                setState(() {
                  category = val!;
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : addExpense,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Add Expense"),
            ),
          ],
        ),
      ),
    );
  }
}
