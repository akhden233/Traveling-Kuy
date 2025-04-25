import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants/constants_flutter.dart';

class ApiServices {
  // Fungsi Sign Up (Register)
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String pass,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$authEndpoint/register'),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode({"name": name, "email": email, "pass": pass}),
      ).timeout(apiTO);

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Sign In Request
  static Future<Map<String, dynamic>> signin(String email, String pass) async {
    try {
      final response = await http.post(
        Uri.parse('$authEndpoint/login'),
        headers: {'Content-Type': "application/json"},
        body: jsonEncode({"email": email, "pass": pass}),
      ).timeout(apiTO);

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$authEndpoint/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(apiTO);

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login Google gagal');
      }
    } catch (e) {
      throw Exception('Gagal login via Google: $e');
    }
  }
}
