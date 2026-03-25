import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/services/api_service.dart';
import '../../expense/screens/add_expense_screen.dart';
import '../../expense/screens/monthly_limit_screen.dart';
import '../../../core/utils/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  double? lastDetectedAmount;
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// ✅ EXPENSE POPUP (FIXED)
  void showExpenseSuggestion(double amount) {
    if (isDialogOpen) return;

    isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("💡 Expense Detected"),
        content: Text("₹$amount spent\nAdd this expense?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              isDialogOpen = false;
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await ApiService().postExpense({
                  "amount": amount,
                  "category": "Others",
                  "note": "Auto detected",
                  "date": DateTime.now().toIso8601String(),
                });

                await NotificationService.show(
                  "Expense Added 💰",
                  "₹$amount added",
                );

                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Expense Added")));

                await fetchData();
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to add expense")),
                );
              }

              isDialogOpen = false;
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  /// ✅ FETCH DATA
  Future<void> fetchData() async {
    try {
      final res = await ApiService().getDashboard();

      if (!mounted) return;

      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load dashboard")));
    }
  }

  Color getColor(double percent) {
    if (percent >= 1) return Colors.red;
    if (percent >= 0.8) return Colors.orange;
    if (percent >= 0.5) return Colors.yellow;
    return const Color(0xFF1A5276);
  }

  String formatDate(String? date) {
    if (date == null) return "";
    final d = DateTime.tryParse(date);
    if (d == null) return "";
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final transactions = data?["recentTransactions"] ?? [];

    double used = (data?["totalExpenses"] ?? 0).toDouble();
    double limit = (data?["limit"] ?? 0).toDouble();
    double percent = limit == 0 ? 0 : (used / limit).clamp(0, 1);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A5276),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );

          if (result == true) await fetchData();
        },
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: fetchData,
        child: Stack(
          children: [
            /// 🌌 Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF1A5276)],
                ),
              ),
            ),

            SafeArea(
              child: loading
                  ? _buildShimmer()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header
                          const Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// 🔥 SET BUDGET BUTTON (ADDED BACK)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MonthlyLimitScreen(),
                                  ),
                                );

                                if (result == true) await fetchData();
                              },
                              child: const Text("Set Monthly Budget"),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// Cards
                          Row(
                            children: [
                              Expanded(
                                child: _glassCard(
                                  title: "Expenses",
                                  value: "₹${data?["totalExpenses"] ?? 0}",
                                  icon: Icons.arrow_downward,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _glassCard(
                                  title: "Balance",
                                  value: "₹${data?["balance"] ?? 0}",
                                  icon: Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          ),

                          if ((data?["balance"] ?? 0) < 0)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                "⚠️ You are overspending!",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                          const SizedBox(height: 20),

                          /// Budget Progress
                          _glassContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Monthly Budget"),
                                const SizedBox(height: 10),
                                Text(
                                  "₹${data?["remaining"] ?? 0} left",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 10,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation(
                                    getColor(percent),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// Transactions
                          const Text("Recent Transactions"),
                          const SizedBox(height: 10),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return _transactionTile(tx);
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_shimmerCard(), _shimmerCard()],
    );
  }

  Widget _shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _glassCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return _glassContainer(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _transactionTile(Map tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: _glassContainer(
        child: ListTile(
          leading: const Icon(Icons.receipt_long),
          title: Text(tx["category"] ?? "Unknown"),
          subtitle: Text(formatDate(tx["date"])),
          trailing: Text("₹${tx["amount"] ?? 0}"),
        ),
      ),
    );
  }
}
