import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../services/sms_service.dart';
import '../services/socket_service.dart';
import '../utils/sms_parser.dart';
import '../services/notification_service.dart';
import 'history_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double monthlyLimit = 10000;
  double totalSpent = 0;

  double cashTotal = 0;
  double onlineTotal = 0;

  bool loading = true;

  List<Expense> expenses = [];

  DateTime budgetMonth = DateTime.now();

  final SmsService smsService = SmsService();
  final SocketService socketService = SocketService();

  Timer? smsTimer;

  @override
  void initState() {
    super.initState();

    loadBudget();
    checkMonthlyReset();
    loadExpenses();

    socketService.connect();

    socketService.listenExpense((data) {
      loadExpenses();
    });

    /// CHECK SMS EVERY 15 SEC
    smsTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchSmsExpenses();
    });
  }

  @override
  void dispose() {
    socketService.socket.dispose();
    smsTimer?.cancel();
    super.dispose();
  }

  /// LOAD BUDGET
  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      monthlyLimit = prefs.getDouble("monthlyLimit") ?? 10000;
    });
  }

  /// SAVE BUDGET
  Future<void> saveBudget(double value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble("monthlyLimit", value);
  }

  /// RESET MONTHLY
  void checkMonthlyReset() {
    DateTime now = DateTime.now();

    if (budgetMonth.month != now.month || budgetMonth.year != now.year) {
      totalSpent = 0;
      expenses.clear();
      budgetMonth = now;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New month started. Budget reset.")),
        );
      });
    }
  }

  /// LOAD EXPENSES
  Future<void> loadExpenses() async {
    try {
      final data = await ApiService.getExpenses();

      expenses = data.map<Expense>((e) => Expense.fromJson(e)).toList();

      calculateTotals();

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load expenses")),
        );
      }
    }
  }

  /// CALCULATE TOTALS
  void calculateTotals() {
    totalSpent = 0;
    cashTotal = 0;
    onlineTotal = 0;

    for (var e in expenses) {
      totalSpent += e.amount;

      if (e.paymentType == "Cash") {
        cashTotal += e.amount;
      } else {
        onlineTotal += e.amount;
      }
    }
  }

  /// AUTO SMS DETECTION
  Future<void> fetchSmsExpenses() async {
    try {
      final messages = await smsService.getMessages();

      for (var sms in messages.take(20)) {
        final transaction = parseTransaction(sms.body ?? "");

        if (transaction != null) {
          bool exists = expenses.any((e) =>
              e.amount == transaction["amount"] &&
              e.note == transaction["note"]);

          if (!exists) {
            await ApiService.addExpense(
              transaction["amount"],
              transaction["category"],
              transaction["paymentType"],
              transaction["note"],
              DateTime.now().toIso8601String(),
            );

            await loadExpenses();

            double remaining = monthlyLimit - totalSpent;

            /// SHOW EXPENSE NOTIFICATION
            await NotificationService.showExpenseNotification(
                transaction["amount"], remaining);

            /// LIMIT WARNING
            if (totalSpent > monthlyLimit) {
              await NotificationService.showLimitWarning();
            }
          }

          break;
        }
      }
    } catch (e) {
      print("SMS Error: $e");
    }
  }

  /// SET BUDGET
  void setLimit() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Monthly Budget"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter budget amount"),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  double value = double.parse(controller.text);

                  setState(() {
                    monthlyLimit = value;
                  });

                  await saveBudget(value);
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// TOP CATEGORY
  String getTopCategory() {
    Map<String, double> data = {};

    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    if (data.isEmpty) return "No data";

    var top = data.entries.reduce((a, b) => a.value > b.value ? a : b);

    return "${top.key} ₹${top.value.toStringAsFixed(0)}";
  }

  /// PROGRESS BAR COLOR
  Color getBudgetColor(double progress) {
    if (progress < 0.4) {
      return Colors.green;
    }

    if (progress < 0.7) {
      return Colors.blue;
    }

    if (progress < 0.9) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    double remaining = monthlyLimit - totalSpent;

    double progress =
        monthlyLimit == 0 ? 0 : (totalSpent / monthlyLimit).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadExpenses,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOTAL SPENT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2E33),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Spent",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹$totalSpent",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// CASH / ONLINE
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Column(
                                children: [
                                  const Icon(Icons.money),
                                  const SizedBox(height: 6),
                                  const Text("Cash"),
                                  const SizedBox(height: 6),
                                  Text("₹$cashTotal"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Column(
                                children: [
                                  const Icon(Icons.credit_card),
                                  const SizedBox(height: 6),
                                  const Text("Online"),
                                  const SizedBox(height: 6),
                                  Text("₹$onlineTotal"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// BUDGET
                    const Text("Monthly Budget"),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      valueColor:
                          AlwaysStoppedAnimation(getBudgetColor(progress)),
                    ),

                    const SizedBox(height: 8),

                    Text("Remaining: ₹$remaining"),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text("Set Monthly Budget"),
                        onPressed: setLimit,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TOP CATEGORY
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.star, color: Colors.orange),
                        title: const Text("Top Category"),
                        trailing: Text(getTopCategory()),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// RECENT
                    const Text(
                      "Recent Transactions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Column(
                      children: expenses.take(5).map((e) {
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              e.paymentType == "Cash"
                                  ? Icons.money
                                  : Icons.credit_card,
                              color: const Color(0xFF4F7C82),
                            ),
                            title: Text(e.note),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.category),
                                Text(
                                  DateFormat("dd MMM yyyy • HH:mm")
                                      .format(e.date),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: Text("₹${e.amount}"),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        child: const Text("View All Transactions"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryScreen(expenses: expenses),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
