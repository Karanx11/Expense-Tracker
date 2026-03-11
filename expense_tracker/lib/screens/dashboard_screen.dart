import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../services/sms_service.dart';
import '../services/socket_service.dart';
import '../utils/sms_parser.dart';
import '../services/notification_service.dart';
import 'history_screen.dart';

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

  @override
  void initState() {
    super.initState();

    checkMonthlyReset();

    loadExpenses();
    fetchSmsExpenses();

    socketService.connect();

    socketService.listenExpense((data) {
      loadExpenses();
    });
  }

  @override
  void dispose() {
    socketService.socket.dispose();
    super.dispose();
  }

  /// RESET BUDGET IF NEW MONTH
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

  /// FETCH EXPENSES
  Future loadExpenses() async {
    try {
      final data = await ApiService.getExpenses();

      expenses = data.map<Expense>((e) => Expense.fromJson(e)).toList();

      calculateTotals();

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load expenses")));
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

  /// AUTO SMS EXPENSE DETECTION
  Future<void> fetchSmsExpenses() async {
    final messages = await smsService.getMessages();

    for (var sms in messages.take(20)) {
      final transaction = parseTransaction(sms.body ?? "");

      if (transaction != null) {
        bool exists = expenses.any(
          (e) =>
              e.amount == transaction["amount"] &&
              e.note == transaction["note"],
        );

        if (!exists) {
          try {
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
              transaction["amount"],
              remaining,
            );

            /// SHOW LIMIT WARNING
            if (totalSpent > monthlyLimit) {
              await NotificationService.showLimitWarning();
            }
          } catch (_) {}
        }

        break;
      }
    }
  }

  /// SET MONTHLY LIMIT
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
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    monthlyLimit = double.parse(controller.text);
                  });
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

  @override
  Widget build(BuildContext context) {
    double remaining = monthlyLimit - totalSpent;

    double progress = monthlyLimit == 0 ? 0 : totalSpent / monthlyLimit;

    if (progress > 1) progress = 1;

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
                            child: ListTile(
                              leading: const Icon(Icons.money),
                              title: const Text("Cash"),
                              trailing: Text("₹$cashTotal"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.credit_card),
                              title: const Text("Online"),
                              trailing: Text("₹$onlineTotal"),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// BUDGET
                    const Text(
                      "Monthly Budget",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(value: progress, minHeight: 10),

                    const SizedBox(height: 8),

                    Text("Remaining: ₹$remaining"),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: setLimit,
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text("Set Monthly Budget"),
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

                    /// RECENT TRANSACTIONS
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                            ),
                            title: Text(e.note),
                            subtitle: Text(e.category),
                            trailing: Text(
                              "₹${e.amount}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// VIEW ALL
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryScreen(expenses: expenses),
                            ),
                          );
                        },
                        child: const Text("View All Transactions"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
