class CategoryDetector {
  static String detect(String text) {
    final msg = text.toLowerCase();

    /// 🍔 FOOD
    if (_containsAny(msg, [
      "swiggy",
      "zomato",
      "restaurant",
      "food",
      "dominos",
      "pizza",
      "burger",
    ])) {
      return "Food";
    }

    /// 🚕 TRAVEL
    if (_containsAny(msg, [
      "uber",
      "ola",
      "rapido",
      "metro",
      "train",
      "bus",
      "irctc",
    ])) {
      return "Travel";
    }

    /// 🛒 SHOPPING
    if (_containsAny(msg, [
      "amazon",
      "flipkart",
      "myntra",
      "meesho",
      "shopping",
    ])) {
      return "Shopping";
    }

    /// 💡 BILLS
    if (_containsAny(msg, [
      "electricity",
      "bill",
      "recharge",
      "dth",
      "gas",
      "water",
    ])) {
      return "Bills";
    }

    /// 💸 DEFAULT
    return "Other";
  }

  /// 🔍 Helper
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((word) => text.contains(word));
  }
}
