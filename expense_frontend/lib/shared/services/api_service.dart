import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = "https://expense-tracker-utc3.onrender.com/api";

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// =========================
  /// 🔐 TOKEN MANAGEMENT
  /// =========================

  Future<void> saveToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  /// ✅ NEW: REMOVE TOKEN (IMPORTANT)
  Future<void> removeToken() async {
    await storage.delete(key: "token");
  }

  /// ✅ OPTIONAL: LOGOUT API (if backend supports)
  Future<void> logout() async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: await _headers(),
      );

      print("LOGOUT STATUS: ${res.statusCode}");
      print("LOGOUT BODY: ${res.body}");
    } catch (e) {
      print("LOGOUT API ERROR: $e");
    }
  }

  /// =========================
  /// 📡 HEADERS
  /// =========================

  Future<Map<String, String>> _headers() async {
    final token = await getToken();

    if (token == null) {
      throw Exception("❌ No token found. Please login again.");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// =========================
  /// 📝 SIGNUP
  /// =========================

  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("SIGNUP STATUS: ${res.statusCode}");
      print("SIGNUP BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Signup failed");
      }
    } catch (e) {
      print("SIGNUP ERROR: $e");
      throw Exception("Signup Error: $e");
    }
  }

  /// =========================
  /// 🔐 LOGIN
  /// =========================

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${res.statusCode}");
      print("LOGIN BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        if (data["token"] != null) {
          await saveToken(data["token"]);
        }
        return data;
      } else {
        throw Exception(data["message"] ?? "Login failed");
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
      throw Exception("Login Error: $e");
    }
  }

  /// =========================
  /// 📊 DASHBOARD
  /// =========================

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/dashboard"),
        headers: await _headers(),
      );

      print("DASHBOARD STATUS: ${res.statusCode}");
      print("DASHBOARD BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to load dashboard");
      }
    } catch (e) {
      print("DASHBOARD ERROR: $e");
      throw Exception("Dashboard Error: $e");
    }
  }

  /// =========================
  /// 💸 ADD EXPENSE
  /// =========================

  Future<Map<String, dynamic>> postExpense(Map body) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/expenses"),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      print("POST EXPENSE STATUS: ${res.statusCode}");
      print("POST EXPENSE BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to add expense");
      }
    } catch (e) {
      print("POST EXPENSE ERROR: $e");
      throw Exception("Expense Error: $e");
    }
  }

  /// =========================
  /// 📈 SET MONTHLY LIMIT
  /// =========================

  Future<Map<String, dynamic>> setLimit(Map body) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/limit"),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      print("SET LIMIT STATUS: ${res.statusCode}");
      print("SET LIMIT BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to set limit");
      }
    } catch (e) {
      print("SET LIMIT ERROR: $e");
      throw Exception("Limit Error: $e");
    }
  }

  /// =========================
  /// 🗑️ DELETE EXPENSE
  /// =========================

  Future<Map<String, dynamic>> deleteExpense(String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/expenses/$id"),
        headers: await _headers(),
      );

      print("DELETE STATUS: ${res.statusCode}");
      print("DELETE BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to delete expense");
      }
    } catch (e) {
      print("DELETE ERROR: $e");
      throw Exception("Delete Error: $e");
    }
  }

  /// =========================
  /// 🔥 RESET EVERYTHING
  /// =========================
  Future<Map<String, dynamic>> resetAll() async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/reset"),
        headers: await _headers(),
      );

      print("RESET STATUS: ${res.statusCode}");
      print("RESET BODY: ${res.body}");

      /// ✅ HANDLE EMPTY RESPONSE SAFELY
      if (res.body.isEmpty) {
        return {"message": "Reset successful"};
      }

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"] ?? "Failed to reset data");
      }
    } catch (e) {
      print("🔥 RESET ERROR: $e");
      throw Exception("Reset Error: $e");
    }
  }
}
