class Expense {
  final String id;
  final double amount;
  final String category;
  final String paymentType;
  final String note;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.paymentType,
    required this.note,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["_id"] ?? "",
      amount: (json["amount"] as num).toDouble(),
      category: json["category"] ?? "",
      paymentType: json["paymentType"] ?? "",
      note: json["note"] ?? "",
      date: DateTime.parse(json["date"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "amount": amount,
      "category": category,
      "paymentType": paymentType,
      "note": note,
      "date": date.toIso8601String(),
    };
  }
}
