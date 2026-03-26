import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryColor = const Color(0xFF606F49);

  List transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final res = await ApiService().getDashboard(); // reuse API

      setState(() {
        transactions = res["recentTransactions"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  /// 🗑️ DELETE
  Future<void> deleteExpense(String id) async {
    await ApiService().deleteExpense(id);
    fetchHistory();
  }

  /// 📅 GROUP BY MONTH
  Map<String, List<Map>> groupByMonth(List data) {
    Map<String, List<Map>> grouped = {};

    for (var tx in data) {
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
    if (d == null) return "";
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupByMonth(transactions);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Transaction History"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0D0D), Color(0xFF1A1F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: fetchHistory,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// MONTH HEADER
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                formatMonth(entry.key),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            /// TRANSACTIONS
                            ...entry.value.map((tx) {
                              return Dismissible(
                                key: Key(tx["_id"]),
                                direction: DismissDirection.endToStart,

                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),

                                onDismissed: (_) {
                                  deleteExpense(tx["_id"]);
                                },

                                child: _card(tx),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _card(Map tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(Icons.receipt_long, color: primaryColor),
              title: Text(
                tx["category"] ?? "Unknown",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                formatDate(tx["date"]),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                "₹${tx["amount"] ?? 0}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
