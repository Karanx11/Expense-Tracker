import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const baseUrl = "http://10.0.2.2:5000/api";

  static Future<Map<String, String>> getHeaders() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}
