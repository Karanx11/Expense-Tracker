import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/services/api_service.dart';
import '../../expense/screens/add_expense_screen.dart';
import '../../expense/screens/monthly_limit_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;
  bool loading = true;

  final Color primaryColor = const Color(0xFF606F49);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// ================= FETCH DATA =================
  Future<void> fetchData() async {
    try {
      final res = await ApiService().getDashboard();

      if (!mounted) return;

      setState(() {
        data = res;
        loading = false;
      });

      /// 🔥 Monthly reset check
      await checkMonthlyReset();
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load dashboard")));
    }
  }

  /// ================= MONTH RESET =================
  Future<void> checkMonthlyReset() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final currentMonth = "${now.year}-${now.month}";

    final savedMonth = prefs.getString("month");

    if (savedMonth != currentMonth) {
      await prefs.setString("month", currentMonth);

      setState(() {
        data?["limit"] = 0;
        data?["totalExpenses"] = 0;
      });
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await ApiService().logout();
    await ApiService().removeToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 10),
              Text("Logout", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
                logout();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  /// ================= HELPERS =================
  Color getColor(double percent) {
    if (percent >= 1) return Colors.red;
    if (percent >= 0.8) return Colors.orange;
    if (percent >= 0.5) return Colors.yellow;
    return primaryColor;
  }

  Map<String, List<Map>> groupByMonth(List transactions) {
    Map<String, List<Map>> grouped = {};
    for (var tx in transactions) {
      final date = DateTime.tryParse(tx["date"] ?? "");
      if (date == null) continue;

      String key = "${date.year}-${date.month}";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tx);
    }
    return grouped;
  }

  String formatMonth(String key) {
    final parts = key.split("-");
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${months[month - 1]} $year";
  }

  String formatDate(String? date) {
    if (date == null) return "";
    final d = DateTime.tryParse(date);
    return d == null ? "" : "${d.day}/${d.month}/${d.year}";
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final transactions = data?["recentTransactions"] ?? [];
    final grouped = groupByMonth(transactions);

    double used = (data?["totalExpenses"] ?? 0).toDouble();
    double limit = (data?["limit"] ?? 0).toDouble();
    double percent = limit == 0 ? 0 : (used / limit).clamp(0, 1);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (res == true) fetchData();
        },
      ),

      body: loading
          ? _buildShimmer()
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ===== GAUGE CARD =====
                    _glassContainer(
                      child: Column(
                        children: [
                          const Text(
                            "Monthly Spending",
                            style: TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SfRadialGauge(
                                  axes: [
                                    RadialAxis(
                                      minimum: 0,
                                      maximum: limit == 0 ? 100 : limit,
                                      startAngle: 180,
                                      endAngle: 0,
                                      showTicks: false,
                                      showLabels: false,
                                      axisLineStyle: const AxisLineStyle(
                                        thickness: 0.18,
                                        thicknessUnit: GaugeSizeUnit.factor,
                                        color: Color(0xFF1E1E1E),
                                      ),
                                      pointers: [
                                        RangePointer(
                                          value: used,
                                          width: 0.18,
                                          sizeUnit: GaugeSizeUnit.factor,
                                          gradient: const SweepGradient(
                                            colors: [
                                              Color(0xFF606F49),
                                              Colors.orange,
                                              Colors.red,
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                /// CENTER TEXT
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "₹${used.toInt()}",
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "of ₹${limit.toInt()}",
                                      style: const TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${(percent * 100).toInt()}%",
                                      style: TextStyle(
                                        color: getColor(percent),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// STATS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _stat("Used", "₹${used.toInt()}", Colors.orange),
                              _stat(
                                "Remaining",
                                "₹${(limit - used).toInt()}",
                                getColor(percent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ===== BUTTON =====
                    GestureDetector(
                      onTap: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MonthlyLimitScreen(),
                          ),
                        );
                        if (res == true) fetchData();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Set Monthly Budget",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// ===== TRANSACTIONS =====
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 10),

                    ...grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatMonth(entry.key),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...entry.value.map((tx) => _transactionTile(tx)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _transactionTile(Map tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx["category"],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatDate(tx["date"]),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Text(
            "₹${tx["amount"]}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
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
}
