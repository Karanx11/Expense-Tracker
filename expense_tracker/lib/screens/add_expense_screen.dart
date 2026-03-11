import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String paymentType = "Cash";
  String category = "Food";

  bool loading = false;

  final formKey = GlobalKey<FormState>();

  List<String> categories = [
    "Food",
    "Shopping",
    "Travel",
    "Bills",
    "Entertainment",
    "Other",
  ];

  Future<void> saveExpense() async {
    if (!formKey.currentState!.validate()) return;

    double amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await ApiService.addExpense(
        amount,
        category,
        paymentType,
        noteController.text,
        DateTime.now().toIso8601String(),
      );

      print("Saving expense...");
      print("Amount: $amount");
      print("Category: $category");

      if (!mounted) return;

      if (result["message"] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense added successfully")),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["error"] ?? "Failed to add expense")),
        );
      }
    } catch (e) {
      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: formKey,

          child: Column(
            children: [
              /// AMOUNT
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
                  }
                  return null;
                },

                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),

              const SizedBox(height: 15),

              /// CATEGORY
              DropdownButtonFormField(
                value: category,
                dropdownColor: const Color(0xFF0B2E33),

                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },

                decoration: const InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category),
                ),
              ),

              const SizedBox(height: 15),

              /// PAYMENT TYPE
              DropdownButtonFormField(
                value: paymentType,
                dropdownColor: const Color(0xFF0B2E33),

                items: const [
                  DropdownMenuItem(value: "Cash", child: Text("Cash")),
                  DropdownMenuItem(value: "Online", child: Text("Online")),
                ],

                onChanged: (value) {
                  setState(() {
                    paymentType = value!;
                  });
                },

                decoration: const InputDecoration(
                  labelText: "Payment Type",
                  prefixIcon: Icon(Icons.payment),
                ),
              ),

              const SizedBox(height: 15),

              /// NOTE
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: "Note",
                  prefixIcon: Icon(Icons.notes),
                ),
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,

                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: saveExpense,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Save Expense",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
