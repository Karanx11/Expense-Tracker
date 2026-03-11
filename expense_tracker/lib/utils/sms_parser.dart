Map<String, dynamic>? parseTransaction(String sms) {
  RegExp amountRegex = RegExp(r'Rs\.?\s?(\d+)');
  final amountMatch = amountRegex.firstMatch(sms);

  if (amountMatch == null) return null;

  double amount = double.parse(amountMatch.group(1)!);

  String merchant = "Unknown";
  String category = "Other";

  String text = sms.toLowerCase();

  if (text.contains("amazon")) {
    merchant = "Amazon";
    category = "Shopping";
  } else if (text.contains("zomato") || text.contains("swiggy")) {
    merchant = "Food App";
    category = "Food";
  } else if (text.contains("uber") || text.contains("ola")) {
    merchant = "Transport";
    category = "Travel";
  } else if (text.contains("netflix") || text.contains("spotify")) {
    merchant = "Subscription";
    category = "Entertainment";
  } else if (text.contains("flipkart")) {
    merchant = "Flipkart";
    category = "Shopping";
  }

  if (text.contains("debited") || text.contains("spent")) {
    return {
      "amount": amount,
      "category": category,
      "paymentType": "Online",
      "note": merchant,
    };
  }

  return null;
}
