import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static String token = "";

  /// Common Headers
  static Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  /// Handle API Response
  static dynamic handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Something went wrong");
    }
  }

  /// LOGIN
  static Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = handleResponse(response);

    if (data["token"] != null) {
      token = data["token"];
    }

    return data;
  }

  /// SIGNUP
  static Future signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return handleResponse(response);
  }

  /// VERIFY OTP
  static Future verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    return handleResponse(response);
  }

  /// FORGOT PASSWORD
  static Future forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return handleResponse(response);
  }

  /// RESET PASSWORD
  static Future resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/auth/reset-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      }),
    );

    return handleResponse(response);
  }

  /// DASHBOARD
  static Future getDashboard() async {
    final response = await http.get(
      Uri.parse("${Constants.baseUrl}/dashboard"),
      headers: headers,
    );

    return handleResponse(response);
  }

  /// GET EXPENSES
  static Future getExpenses() async {
    final response = await http.get(
      Uri.parse("${Constants.baseUrl}/expenses"),
      headers: headers,
    );

    return handleResponse(response);
  }

  /// ADD EXPENSE
  static Future addExpense(
    String title,
    double amount,
    String category,
    String note,
    String date,
  ) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/expenses"),
      headers: headers,
      body: jsonEncode({
        "title": title,
        "amount": amount,
        "category": category,
        "note": note,
        "date": date,
      }),
    );

    return handleResponse(response);
  }

  /// DELETE EXPENSE
  static Future deleteExpense(String id) async {
    final response = await http.delete(
      Uri.parse("${Constants.baseUrl}/expenses/$id"),
      headers: headers,
    );

    return handleResponse(response);
  }

  /// WALLET
  static Future addCash(double amount) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/wallet/add"),
      headers: headers,
      body: jsonEncode({"amount": amount}),
    );

    return handleResponse(response);
  }

  static Future deductCash(double amount) async {
    final response = await http.post(
      Uri.parse("${Constants.baseUrl}/wallet/deduct"),
      headers: headers,
      body: jsonEncode({"amount": amount}),
    );

    return handleResponse(response);
  }

  /// ANALYTICS
  static Future getMonthlyAnalytics() async {
    final response = await http.get(
      Uri.parse("${Constants.baseUrl}/analytics/monthly"),
      headers: headers,
    );

    return handleResponse(response);
  }

  static Future getCategoryAnalytics() async {
    final response = await http.get(
      Uri.parse("${Constants.baseUrl}/analytics/category"),
      headers: headers,
    );

    return handleResponse(response);
  }

  /// PROFILE
  static Future getProfile() async {
    final response = await http.get(
      Uri.parse("${Constants.baseUrl}/auth/profile"),
      headers: headers,
    );

    return handleResponse(response);
  }

  /// DELETE ACCOUNT
  static Future deleteAccount() async {
    final response = await http.delete(
      Uri.parse("${Constants.baseUrl}/auth/delete-account"),
      headers: headers,
    );

    return handleResponse(response);
  }
}
