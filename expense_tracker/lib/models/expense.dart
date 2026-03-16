class Expense {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  /// Convert JSON → Expense
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["_id"] ?? json["id"],

      amount: (json["amount"] as num).toDouble(),

      category: json["category"] ?? "Other",

      note: json["note"] ?? "",

      date: DateTime.parse(json["date"]),
    );
  }
}
