import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:http/http.dart' as http;
import '../repositories/session_service.dart';

class AuthController {
  final http.Client client;
  final SessionService session;

  AuthController({http.Client? client, SessionService? sessionService})
      : client = client ?? http.Client(),
        session = sessionService ?? SessionService();

  // --- 1. CONFIG URL OTOMATIS ---
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/moodq_api";
    } else {
      return "http://192.168.1.11/moodq_api";
    }
  }

  // --- 2. FUNGSI LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login.php');
      print("Login Request to: $url"); // Debug URL

      final response = await client
          .post(url, body: {'email': email, 'password': password})
          .timeout(const Duration(seconds: 10));

      print("Login Response: ${response.body}"); // Debug Response

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // JIKA LOGIN SUKSES -> SIMPAN DATA KE MEMORI HP
        if (data['success'] == true) {
          await session.saveFromResponse(data);
        }

        return data;
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } on TimeoutException catch (e) {
      print("Login Timeout: $e");
      return {"success": false, "message": "Request timed out"};
    } catch (e) {
      print("Login Error: $e");
      return {"success": false, "message": "Connection Error: $e"};
    }
  }

  // --- 3. FUNGSI REGISTER ---
  Future<Map<String, dynamic>> register(String name, String email, String password, List<String> goals) async {
    try {
      final url = Uri.parse('$baseUrl/register.php');
      print("Register Request to: $url");

      final response = await client
          .post(url, body: {
        'name': name,
        'email': email,
        'password': password,
        'goals': jsonEncode(goals), // Ubah List goals jadi String JSON
      })
          .timeout(const Duration(seconds: 10));

      print("Register Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Opsional: Jika register PHP langsung mengembalikan data user, simpan sesi juga
        if (data['success'] == true && data.containsKey('user')) {
          await session.saveFromResponse(data);
        }

        return data;
      } else {
        return {"success": false, "message": "Server Error"};
      }
    } on TimeoutException {
      return {"success": false, "message": "Request timed out"};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // --- 4. FUNGSI LOGOUT ---
  Future<void> logout() async {
    await session.clear();
    print("User Logged Out & Session Cleared");
  }

  // --- 5. REQUEST PASSWORD RESET (OTP FLOW) ---
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final url = Uri.parse('$baseUrl/request_reset.php');
      print("Request Reset to: $url");

      final response = await client
          .post(url, body: {'email': email})
          .timeout(const Duration(seconds: 10));

      print("Request Reset Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } on TimeoutException {
      return {"success": false, "message": "Request timed out"};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // --- 6. CHANGE PASSWORD (no OTP) ---
  Future<Map<String, dynamic>> changePassword(String email, String newPassword) async {
    try {
      final url = Uri.parse('$baseUrl/change_password.php');
      print("Change Password to: $url");

      final response = await client
          .post(url, body: {'email': email, 'new_password': newPassword})
          .timeout(const Duration(seconds: 10));

      print("Change Password Response: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        return {"success": false, "message": "Server Error: ${response.statusCode}"};
      }
    } on TimeoutException {
      return {"success": false, "message": "Request timed out"};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // --- 6. CEK APAKAH USER SUDAH LOGIN ---
  Future<bool> isLoggedIn() async {
    return session.isLoggedIn();
  }
}