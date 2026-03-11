import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Expense> expenses = [];
  bool loading = true;

  /// COLORS FOR PIE CHART
  final List<Color> pieColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  /// FETCH EXPENSES
  Future loadExpenses() async {
    try {
      final data = await ApiService.getExpenses();

      expenses = data.map<Expense>((e) => Expense.fromJson(e)).toList();

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load analytics")));
    }
  }

  /// CATEGORY TOTALS
  Map<String, double> calculateCategoryTotals() {
    Map<String, double> data = {};

    for (var e in expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (expenses.isEmpty) {
      return const Scaffold(body: Center(child: Text("No analytics data yet")));
    }

    final categoryTotals = calculateCategoryTotals();

    int index = 0;

    /// PIE CHART SECTIONS
    List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      final color = pieColors[index % pieColors.length];

      final section = PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 90,
        color: color,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

      index++;

      return section;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Expense Analytics")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// CATEGORY PIE CHART
            const Text(
              "Category Spending",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// CATEGORY BREAKDOWN
            const Text(
              "Category Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Column(
              children: categoryTotals.entries.map((entry) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          pieColors[categoryTotals.keys.toList().indexOf(
                                entry.key,
                              ) %
                              pieColors.length],
                    ),
                    title: Text(entry.key),
                    trailing: Text("₹${entry.value.toStringAsFixed(0)}"),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
