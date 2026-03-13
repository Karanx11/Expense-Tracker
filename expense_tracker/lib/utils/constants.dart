class ApiConstants {
  static const String baseUrl = "https://expense-backend-sz71.onrender.com/api";

  static const String signup = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/login";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";

  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";

  static const String profile = "$baseUrl/user/profile";
  static const String updateProfile = "$baseUrl/user/update";
  static const String deleteAccount = "$baseUrl/user/delete";

  static const String addExpense = "$baseUrl/expenses/add";
  static const String getExpenses = "$baseUrl/expenses";
  static const String analytics = "$baseUrl/expenses/analytics";
}
