import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiServices {
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async{
  final response = await http.post(
    Uri.parse('$BASE_URL$endpoint'),
    headers: {'Content-Type': "application/json"},
    body: jsonEncode(body),
  );
  return jsonDecode(response.body);
  }
}