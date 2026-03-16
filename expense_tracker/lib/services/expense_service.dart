import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/expense.dart';
import 'api_service.dart';

class ExpenseService {
  /// GET ALL EXPENSES
  static Future<List<Expense>> getExpenses() async {
    final headers = await ApiService.getHeaders();

    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/expenses/all"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load expenses");
    }
  }

  /// ADD EXPENSE
  static Future<void> addExpense(
    double amount,
    String category,
    String note,
  ) async {
    final headers = await ApiService.getHeaders();

    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/expenses/add"),
      headers: headers,

      body: jsonEncode({"amount": amount, "category": category, "note": note}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add expense");
    }
  }

  /// DELETE EXPENSE
  static Future<void> deleteExpense(String id) async {
    final headers = await ApiService.getHeaders();

    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/expenses/$id"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete expense");
    }
  }
}
