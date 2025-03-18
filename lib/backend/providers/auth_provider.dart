import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User?_user;
  String baseUrl = 'http://localhost:8080'; // Url Backend
  User? get user => _user;

  // fungsi masuk ke alamat SignUP
  Future<bool> register(String name, String email, String, pass) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "pass": pass}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _user = User(uid: data['uid'], name: name, email: email, pass: pass, token: data['token']);
      return true;
    } else {
      throw Exception(data['message']);
    }
  }

  // fungsi masuk ke alamat SignIn
  Future<bool> login(String email, String pass) async{
    final url = Uri.parse("$baseUrl/login");
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body:  jsonEncode({"email": email, "pass": pass}),
      );

    final data = jsonDecode(response.body);
    print('Response data: $data'); // Untuk Debug

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      
      _user = User(
        uid: data['uid'] ?? 0, 
        name: data['name'] ?? '', 
        email: email, 
        pass: '', 
        token: data['token'] ?? ''
      );

      notifyListeners();
      return true;
    }else {
      throw Exception(data['message']);
    }
  } catch (e) {
    print('Login Error: $e'); // Untuk Debug
    return false;
  }
}

  // fungsi logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    notifyListeners();
  }

  // // fungsi save token
  // Future<void> _saveToken(String token) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('token', token);
  // }

  // load dari local storage
  Future<void> loadUserFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      _user = User(uid: 0, name: '', email: '', pass: '', token: token);
      notifyListeners();
    }
  }

  // cek kondisi user (login atau tidak)
  Future<bool> checkLogin() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      return true;
    }else {
      return false;
    }
  }
}