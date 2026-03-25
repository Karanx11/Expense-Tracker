class InsightService {
  /// 🔥 1. Daily Spending Insight
  static String dailyInsight(double todaySpent) {
    if (todaySpent > 2000) {
      return "⚠️ High spending today! Try to slow down.";
    } else if (todaySpent > 1000) {
      return "📊 Moderate spending today.";
    } else {
      return "✅ Great control on spending today!";
    }
  }

  /// 🔥 2. Category Overuse
  static String categoryInsight(String category, double amount) {
    if (category == "Food" && amount > 500) {
      return "🍔 You're spending a lot on food today!";
    }
    if (category == "Shopping" && amount > 1000) {
      return "🛒 Shopping spike detected!";
    }
    return "";
  }

  /// 🔥 3. Budget Insight
  static String budgetInsight(double percentUsed) {
    if (percentUsed >= 1) {
      return "🚨 Budget exceeded!";
    } else if (percentUsed >= 0.8) {
      return "⚠️ You're close to your monthly limit.";
    } else if (percentUsed >= 0.5) {
      return "📊 You've used 50% of your budget.";
    }
    return "";
  }

  /// 🔥 4. Unusual Spending Detection
  static String unusualSpending(double current, double avg) {
    if (current > avg * 2) {
      return "🤯 This expense is much higher than usual!";
    }
    return "";
  }
}
