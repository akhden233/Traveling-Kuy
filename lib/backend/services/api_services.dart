import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiServices {
  // Fungsi Sign Up (Register)
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String pass,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({"name": name, "email": email, "pass": pass}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': 'Sign Up Failed', 'statusCode': response.statusCode};
    }
  }

  // Sign In Request
  static Future<Map<String, dynamic>> signin(
    String name,
    String email,
    String pass,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({"email": email, "pass": pass}),
    );
    return jsonDecode(response.body);
  }
}
