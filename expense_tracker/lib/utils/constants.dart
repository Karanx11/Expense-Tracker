class ApiConstants {
  static const String baseUrl = "https://expense-backend-sz71.onrender.com/api";

  /// AUTH
  static const String signup = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/login";
  static const String sendOtp = "$baseUrl/auth/send-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";

  /// USER
  static const String profile = "$baseUrl/user/profile";
  static const String deleteAccount = "$baseUrl/user/delete";

  /// EXPENSE
  static const String addExpense = "$baseUrl/expense/add";
  static const String getExpenses = "$baseUrl/expense/list";
}
