Map<String, dynamic>? parseTransaction(String sms) {
  sms = sms.toLowerCase();

  /// detect debit transactions
  if (!(sms.contains("debited") ||
      sms.contains("spent") ||
      sms.contains("paid"))) {
    return null;
  }

  /// detect amount (supports INR 1.00, Rs 120, ₹350)
  RegExp amountRegex = RegExp(r'(₹|rs\.?|inr)\s?(\d+(\.\d+)?)');

  var match = amountRegex.firstMatch(sms);

  if (match == null) return null;

  double amount = double.parse(match.group(2)!);

  /// category detection
  String category = "Other";

  if (sms.contains("swiggy") || sms.contains("zomato")) {
    category = "Food";
  } else if (sms.contains("amazon") || sms.contains("flipkart")) {
    category = "Shopping";
  } else if (sms.contains("uber") || sms.contains("ola")) {
    category = "Travel";
  }

  return {
    "amount": amount,
    "category": category,
    "paymentType": "Online",
    "note": "UPI Payment"
  };
}
