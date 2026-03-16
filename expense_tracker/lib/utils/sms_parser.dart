class ParsedSMS {
  double? amount;
  DateTime? dateTime;
  String category;

  ParsedSMS({this.amount, this.dateTime, this.category = "Other"});
}

/// Ignore OTP messages
bool isOtpMessage(String message) {
  message = message.toLowerCase();

  return message.contains("otp") ||
      message.contains("one time password") ||
      message.contains("verification code") ||
      message.contains("login code") ||
      message.contains("security code");
}

/// Detect merchant category
String detectCategory(String message) {
  message = message.toLowerCase();

  if (message.contains("swiggy") ||
      message.contains("zomato") ||
      message.contains("dominos") ||
      message.contains("pizza")) {
    return "Food";
  }

  if (message.contains("amazon") ||
      message.contains("flipkart") ||
      message.contains("myntra") ||
      message.contains("meesho")) {
    return "Shopping";
  }

  if (message.contains("uber") ||
      message.contains("ola") ||
      message.contains("rapido")) {
    return "Travel";
  }

  if (message.contains("petrol") ||
      message.contains("fuel") ||
      message.contains("indianoil") ||
      message.contains("hpcl")) {
    return "Fuel";
  }

  if (message.contains("atm")) {
    return "Cash Withdrawal";
  }

  if (message.contains("upi")) {
    return "UPI";
  }

  return "Other";
}

/// Parse Bank SMS
ParsedSMS? parseBankSMS(String message) {
  message = message.toLowerCase();

  // Ignore OTP messages
  if (isOtpMessage(message)) {
    return null;
  }

  ParsedSMS result = ParsedSMS();

  /// Detect amount
  RegExp amountRegex = RegExp(r'inr\s?(\d+(\.\d+)?)');
  Match? amountMatch = amountRegex.firstMatch(message);

  if (amountMatch != null) {
    result.amount = double.tryParse(amountMatch.group(1)!);
  }

  /// Detect date
  RegExp dateRegex = RegExp(r'(\d{2}-\d{2}-\d{2})');
  Match? dateMatch = dateRegex.firstMatch(message);

  /// Detect time
  RegExp timeRegex = RegExp(r'(\d{2}:\d{2}:\d{2})');
  Match? timeMatch = timeRegex.firstMatch(message);

  if (dateMatch != null && timeMatch != null) {
    String date = dateMatch.group(1)!;
    String time = timeMatch.group(1)!;

    List<String> d = date.split("-");
    List<String> t = time.split(":");

    result.dateTime = DateTime(
      2000 + int.parse(d[2]),
      int.parse(d[1]),
      int.parse(d[0]),
      int.parse(t[0]),
      int.parse(t[1]),
    );
  }

  /// Detect category
  result.category = detectCategory(message);

  return result;
}
