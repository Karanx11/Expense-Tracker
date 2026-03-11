import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.30.227.31:5000/api";
  static String token = "";

  /// SAVE TOKEN
  static Future saveToken(String value) async {
    token = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", value);
  }

  /// LOAD TOKEN
  static Future loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
  }

  /// LOGOUT
  static Future clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    token = "";
  }

  /// SIGNUP
  static Future signup(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  //forgot pasword
  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");

    token = "";
  }

  /// LOGIN
  static Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  /// SEND OTP
  static Future sendOtp(String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    return jsonDecode(response.body);
  }

  /// VERIFY OTP
  static Future verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    return jsonDecode(response.body);
  }

  //RESET PASSWORD
  static Future forgotPassword(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  /// GET PROFILE
  static Future getProfile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/profile"),
      headers: {"Content-Type": "application/json", "Authorization": token},
    );

    return jsonDecode(response.body);
  }

  /// DELETE ACCOUNT
  static Future deleteAccount() async {
    final response = await http.delete(
      Uri.parse("$baseUrl/user/delete"),
      headers: {"Content-Type": "application/json", "Authorization": token},
    );

    return jsonDecode(response.body);
  }

  //EXPENSE
  static Future addExpense(
    double amount,
    String category,
    String paymentType,
    String note,
    String date,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/expense/add"),
      headers: {"Content-Type": "application/json", "Authorization": token},
      body: jsonEncode({
        "amount": amount,
        "category": category,
        "paymentType": paymentType,
        "note": note,
        "date": date,
      }),
    );

    return jsonDecode(response.body);
  }

  //GET EXPENSE
  static Future getExpenses() async {
    final response = await http.get(
      Uri.parse("$baseUrl/expense/list"),
      headers: {"Content-Type": "application/json", "Authorization": token},
    );

    return jsonDecode(response.body);
  }

  //DELETE EXPENSE
  static Future deleteExpense(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/expense/$id"),
      headers: {"Content-Type": "application/json", "Authorization": token},
    );

    return jsonDecode(response.body);
  }
}
