import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User?_user;

  User? get user => _user;

  Future<void> register(String name, String email, String, pass) async {
    final url = Uri.parse("$BASE_URL/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "pass": pass}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(data['message']);
    } else {
      throw Exception(data['message']);
    }
  }

  Future<void> login(String email, String pass) async{
    final url = Uri.parse("$BASE_URL/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body:  jsonEncode({"email": email, "pass": pass}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _user = User.fromJson(data);
      notifyListeners();
    }else {
      throw Exception(data['message']);
    }
  }
}