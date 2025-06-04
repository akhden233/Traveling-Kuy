import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants/constants_flutter.dart';
import '../utils/validators.dart';

class UserprofileProvider extends ChangeNotifier {
  // get model user
  User? _user;
  User? get user => _user;

  // throw error message to frontend
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // fungsi get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // load dari local storage
  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final uid = prefs.getInt('uid');
      final firebase_id = prefs.getString('firebase_id');
      final name = prefs.getString('name') ?? '';
      final email = prefs.getString('email') ?? '';
      final photoUrl = prefs.getString('photoUrl') ?? '';

      if (token != null && uid != null) {
        _user = User(
          uid: uid,
          firebase_id: firebase_id ?? '',
          name: name,
          email: email,
          token: token,
          photoUrl: photoUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      dev.log('[ERROR] Gagal load dari penyimpanan: $e');
    }
  }

  Future<void> clearUserData() async {
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // fungsi update profil
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? photoUrl,
    String? currentPassword,
    String? newPassword,
  }) async {
    name = name.trim();
    email = email.trim();
    currentPassword = currentPassword?.trim();
    newPassword = newPassword?.trim();

    final token = await getToken();
    if (token == null) {
      _errorMessage = 'User belum login';
      notifyListeners();
      throw Exception('User belum login');
    }

    if (name.isEmpty || email.isEmpty) {
      _errorMessage = 'Nama dan Email tidak boleh kosong';
      notifyListeners();
      throw Exception('Nama dan Email tidak boleh kosong');
    }

    final url = Uri.parse('$userProfileEndpoint/profile');

    Map<String, dynamic> body = {
      'uid': _user?.uid,
      'name': name,
      'email': email,
    };

    // validator password min. 8 karakter
    if (currentPassword != null && newPassword != null) {
      if (!Validators.isValidPassword(newPassword)) {
        throw Exception('Password baru harus minimal 8 karakter');
      }
      body['currentPassword'] = currentPassword;
      body['newPassword'] = newPassword;
    } else if (currentPassword != null || newPassword != null) {
      throw Exception('Password lama dan baru harus diisi');
    }

    // convert Base64 to String
    if (photoUrl != null) {
      try {
        body['photoUrl'] = photoUrl;
      } catch (e) {
        throw Exception('Gagal membaca foto: $e');
      }
    }

    try {
      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(apiTO);

      // Debug log to inspect the response
      dev.log('[DEBUG] Response Status Code: ${response.statusCode}');
      dev.log('[DEBUG] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // parse / decode server response
        final data = jsonDecode(response.body);

        final updatedPhotoUrl = data['photoUrl'] ?? _user?.photoUrl ?? '';

        // update local data (shared prefs)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('uid', _user?.uid ?? 0);
        await prefs.setString('firebase_id', _user?.firebase_id ?? '');
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setString('photoUrl', updatedPhotoUrl);

        setUser(
          User(
            uid: _user?.uid ?? 0,
            firebase_id: _user?.firebase_id ?? '',
            name: name,
            email: email,
            token: token,
            photoUrl: updatedPhotoUrl,
          ),
        );

        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        dev.log('[ERROR] Server responded with error: ${response.statusCode}');
        try {
          final data = jsonDecode(response.body);
          final error = data['error'] ?? 'Gagal update data profil';
          throw Exception(error);
        } catch (_) {
          throw Exception('Gagal membaca respon server');
        }
      }
    } on TimeoutException {
      throw Exception('Koneksi Server Timeout');
    } on SocketException {
      throw Exception('Tidak terhubung ke server');
    } catch (e) {
      dev.log('[ERROR] Update Profile: $e');
      _errorMessage = 'Update Profil gagal: $e';
      notifyListeners();
      throw Exception('Update Profil gagal: $e');
    }
  }
}
