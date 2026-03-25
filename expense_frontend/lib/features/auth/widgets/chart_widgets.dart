import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final List data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return PieChart(
      PieChartData(
        sections: data.map((item) {
          return PieChartSectionData(
            value: (item["total"] as num).toDouble(),
            title: item["_id"],
            radius: 60,
          );
        }).toList(),
      ),
    );
  }
}

class DailyLineChart extends StatelessWidget {
  final List data;

  const DailyLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: data.map((item) {
              return FlSpot(
                (item["_id"] as num).toDouble(),
                (item["total"] as num).toDouble(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
