import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';
import '../widgets/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int touchedIndex = -1;

  final colors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Expense>>(
        future: ExpenseService.getExpenses(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No expense data available"));
          }

          final expenses = snapshot.data!;

          /// CATEGORY TOTALS
          Map<String, double> categoryTotals = {};

          for (var expense in expenses) {
            categoryTotals.update(
              expense.category,
              (value) => value + expense.amount,
              ifAbsent: () => expense.amount,
            );
          }

          /// PIE CHART SECTIONS
          List<PieChartSectionData> sections = [];

          int i = 0;

          categoryTotals.forEach((category, total) {
            final isTouched = i == touchedIndex;

            final radius = isTouched ? 110.0 : 90.0;

            sections.add(
              PieChartSectionData(
                value: total,
                title: "₹${total.toInt()}",
                color: colors[i % colors.length],
                radius: radius,

                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );

            i++;
          });

          return Container(
            padding: const EdgeInsets.all(20),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1115), Color(0xFF1A1C22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Analytics",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  /// PIE CHART
                  GlassCard(
                    height: 320,

                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }

                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),

                        sections: sections,
                        centerSpaceRadius: 50,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  /// CATEGORY LIST
                  Expanded(
                    child: ListView(
                      children: categoryTotals.entries.map((entry) {
                        int index = categoryTotals.keys.toList().indexOf(
                          entry.key,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),

                          child: GlassCard(
                            height: 70,

                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,

                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                /// CATEGORY NAME
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// AMOUNT
                                Text(
                                  "₹${entry.value.toStringAsFixed(0)}",

                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
