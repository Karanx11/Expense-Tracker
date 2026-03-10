import 'package:expense_tracker_app_frontend/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double walletBalance = 0;
  double totalExpenses = 0;
  double balance = 0;

  double expenseLimit = 5000;

  String userName = "";
  String userEmail = "";

  List recentTransactions = [];

  List<FlSpot> monthlySpots = [];
  List<PieChartSectionData> categorySections = [];

  bool isLoading = true;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future fetchDashboard() async {
    try {
      final dashboard = await ApiService.getDashboard();
      final monthly = await ApiService.getMonthlyAnalytics();
      final category = await ApiService.getCategoryAnalytics();
      final profile = await ApiService.getProfile();

      setState(() {
        walletBalance = (dashboard["walletBalance"] ?? 0).toDouble();
        totalExpenses = (dashboard["totalExpenses"] ?? 0).toDouble();
        balance = (dashboard["balance"] ?? 0).toDouble();

        userName = profile["name"] ?? "";
        userEmail = profile["email"] ?? "";

        recentTransactions = dashboard["recentTransactions"] ?? [];

        monthlySpots = monthly.map<FlSpot>((m) {
          return FlSpot(
            (m["_id"] ?? 0).toDouble(),
            (m["total"] ?? 0).toDouble(),
          );
        }).toList();

        categorySections = category.map<PieChartSectionData>((c) {
          Color color = Colors.blue;

          if (c["_id"] == "Food") color = Colors.orange;
          if (c["_id"] == "Travel") color = Colors.blue;
          if (c["_id"] == "Shopping") color = Colors.purple;
          if (c["_id"] == "Bills") color = Colors.red;

          return PieChartSectionData(
            value: (c["total"] ?? 0).toDouble(),
            color: color,
            title: c["_id"],
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );

          fetchDashboard();
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E293B),

        currentIndex: selectedIndex,

        selectedItemColor: Colors.green,

        unselectedItemColor: Colors.white60,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              greetingSection(),

              const SizedBox(height: 20),

              walletSection(),

              const SizedBox(height: 20),

              buildBudgetBar(),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: buildCard(
                      "Total Expenses",
                      "₹${totalExpenses.toStringAsFixed(0)}",
                      Colors.red,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: buildCard(
                      "Balance",
                      "₹${balance.toStringAsFixed(0)}",
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Transactions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...recentTransactions.map((t) {
                return transactionTile(
                  t["title"] ?? "",
                  "- ₹${t["amount"]}",
                  t["category"] ?? "",
                );
              }).toList(),

              const SizedBox(height: 30),

              const Text(
                "Monthly Expenses",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: monthlySpots.isEmpty
                            ? [const FlSpot(0, 0)]
                            : monthlySpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Category Breakdown",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 200,
                child: PieChart(PieChartData(sections: categorySections)),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget greetingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Good Evening 👋",
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),

            const SizedBox(height: 4),

            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              userEmail,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(name: userName, email: userEmail),
              ),
            );
          },
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget walletSection() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Wallet Balance", style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 8),

          Text(
            "₹${walletBalance.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: addCashDialog,
                  child: const Text("Add Cash"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: deductCashDialog,
                  child: const Text("Deduct Cash"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBudgetBar() {
    double percent = expenseLimit == 0 ? 0 : totalExpenses / expenseLimit;
    percent = percent.clamp(0, 1);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Monthly Budget",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextButton(
                onPressed: setLimitDialog,
                child: const Text(
                  "Set Limit",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: percent,
            minHeight: 12,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),

          const SizedBox(height: 10),

          Text(
            "₹${(expenseLimit - totalExpenses).toStringAsFixed(0)} left",
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60)),

          const SizedBox(height: 6),

          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionTile(String title, String amount, String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.money, color: Colors.white),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),

                Text(category, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),

          Text(
            amount,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void addCashDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Cash"),

        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),

        actions: [
          TextButton(
            onPressed: () async {
              double amount = double.tryParse(controller.text) ?? 0;

              if (amount <= 0) return;

              await ApiService.addCash(amount);

              Navigator.pop(context);

              fetchDashboard();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void setLimitDialog() {
    TextEditingController controller = TextEditingController(
      text: expenseLimit.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Monthly Budget"),

        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter Budget Limit"),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              double newLimit = double.tryParse(controller.text) ?? 0;

              if (newLimit <= 0) return;

              setState(() {
                expenseLimit = newLimit;
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deductCashDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Deduct Cash"),

        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),

        actions: [
          TextButton(
            onPressed: () async {
              double amount = double.tryParse(controller.text) ?? 0;

              if (amount <= 0) return;

              await ApiService.deductCash(amount);

              Navigator.pop(context);

              fetchDashboard();
            },
            child: const Text("Deduct"),
          ),
        ],
      ),
    );
  }
}
