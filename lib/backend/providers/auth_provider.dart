import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../screens/user_profile.dart';
import '../models/user_model.dart' as local;
import '../utils/constants/constants_flutter.dart';
import '../utils/validators.dart';

class AuthProvider extends ChangeNotifier {
  // get model user
  local.User? _user;
  local.User? get user => _user;

  // throw error message to frontend
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setUser(local.User user) {
    _user = user;
    notifyListeners();
  }

  // Firebase google auth
  final fire_auth.FirebaseAuth _firebaseAuth = fire_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // fungsi masuk ke alamat SignUP
  Future<bool> register(String name, String email, String pass) async {
    // Validasi password
    if (pass.length < 8) {
      print('[ERROR] Password too short');
      throw Exception('Password harus minimal 8 karakter');
    }

    final url = Uri.parse("$authEndpoint/register");
    print('[DEBUG] Register URL: $url');
    print(
      '[DEBUG] Register Data: {"name": "$name", "email": "$email", "pass": "***"}',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"name": name, "email": email, "pass": pass}),
          )
          .timeout(apiTO);

      print('[DEBUG] Register Response Status: ${response.statusCode}');
      print('[DEBUG] Register Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        // Jika gagal, parse error message
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } on TimeoutException {
      print('[ERROR] Register Timeout');
      throw Exception('Connection timeout. Please try again.');
    } on FormatException {
      print('[ERROR] Register Format Error');
      throw Exception('Invalid response format from server');
    } on SocketException {
      print('[ERROR] Socket Exception');
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan server berjalan.',
      );
    } catch (e) {
      print('[ERROR] Register Error: $e');
      _errorMessage = 'Registration Failed: $e';
      throw Exception(_errorMessage);
    }
  }

  // fungsi Login (Local)
  Future<bool> login(String email, String pass) async {
    // Validasi password
    if (pass.length < 8) {
      print('[ERROR] Password too short');
      throw Exception('Password harus minimal 8 karakter');
    }

    final url = Uri.parse("$authEndpoint/login");

    print('[DEBUG] Login URL: $url');
    print('[DEBUG] Login Data: {"email": "$email", "pass": "***"}');

    try {
      print('[DEBUG] Attempting to connect to server...');

      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({"email": email, "pass": pass}),
          )
          .timeout(apiTO);

      print('[DEBUG] Response received. Status: ${response.statusCode}');
      print('[DEBUG] Response Headers: ${response.headers}');
      print('[DEBUG] Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] == null ||
            data['uid'] == null ||
            data['name'] == null) {
          print('[ERROR] Login Invalid Response Format');
          throw Exception('Invalid response format from server');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('uid', data['uid']);
        await prefs.setString('name', data['name']);
        await prefs.setString('email', email);
        await prefs.setString('photoUrl', data['photoUrl']?.toString() ?? '');

        // Add debug log for photoUrl value
        print('[DEBUG] photoUrl from login response: ${data['photoUrl']}');
        print(
          '[DEBUG] Saving photoUrl to SharedPreferences and updating notifier',
        );

        // Update profileImageNotifier => refresh UI setelah Login
        profileImageNotifier.value = data['photoUrl']?.toString() ?? '';
        print(
          '[DEBUG] profileImageNotifier updated during login with length: \${profileImageNotifier.value.length}',
        );

        await prefs.setString('firebase_id', data['firebase_id'] ?? '');

        setUser(
          local.User(
            uid: data['uid'],
            firebase_id: data['firebase_id'] ?? '',
            name: data['name'],
            email: email,
            token: data['token'],
            photoUrl: data['photoUrl']?.toString() ?? '',
          ),
        );
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        dev.log('[ERROR] Login Failed: ${data['message']}');
        throw Exception(data['message'] ?? 'Login failed');
      }
    } on TimeoutException {
      print('[ERROR] Login Timeout');
      throw Exception('Connection timeout. Please try again.');
    } on FormatException {
      print('[ERROR] Login Format Error');
      throw Exception('Invalid response format from server');
    } on SocketException {
      print('[ERROR] Socket Exception');
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan server berjalan.',
      );
    } catch (e) {
      dev.log('[ERROR] Login Error: $e');
      throw Exception('Login failed');
    }
  }

  // fungsi login(google)
  Future<bool> authGoogle() async {
    try {
      // auth google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fire_auth.AuthCredential credential = fire_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // auth ke firebase
      final fire_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final fire_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        dev.log('[ERROR] FirebaseUser null setelah signInWithCredential');
        throw Exception('Failed to Sign in with Google');
      }

      // get token from firebase
      final String? firebaseToken = await firebaseUser.getIdToken(true);
      final String firebase_id = firebaseUser.uid;
      final String name = firebaseUser.displayName ?? '';
      final String email = firebaseUser.email!;
      final String? photoUrl = firebaseUser.photoURL;

      // Debug logs for token and user data
      dev.log('[DEBUG] Firebase Token: $firebaseToken');
      dev.log('[DEBUG] User ID: $firebase_id');
      dev.log('[DEBUG] User Email: $email');
      dev.log('[DEBUG] User Name: $name');

      // send to backend
      final url = Uri.parse('$authEndpoint/google');
      final response = await http
          .post(
            url,
            body: jsonEncode({
              'firebase_id': firebase_id,
              'name': name,
              'email': email,
              'photoUrl': photoUrl,
            }),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $firebaseToken',
            },
          )
          .timeout(apiTO);

      print('[DEBUG] Google Auth response status: ${response.statusCode}');
      print('[DEBUG] Google Auth response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // validasi response
        if (data['token'] == null ||
            data['uid'] == null ||
            name.isEmpty ||
            email.isEmpty) {
          print('[ERROR] Login Invalid Response Format');
          throw Exception('Invalid response format from server');
        }

        // save token dan data user ke local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('firebase_id', firebase_id);
        await prefs.setInt('uid', data['uid']);
        await prefs.setString('email', email);
        await prefs.setString('name', name);
        await prefs.setString(
          'photoUrl',
          data['photoUrl']?.toString() ?? photoUrl ?? '',
        );

        _user = local.User(
          uid: data['uid'],
          firebase_id: firebase_id,
          name: name,
          email: email,
          token: data['token'],
          photoUrl: data['photoUrl'].toString() ?? '',
        );

        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Google auth gagal (server)';
        throw Exception(_errorMessage);
      }
    } on TimeoutException {
      _errorMessage = 'TimeOut saat menghubungkan ke server';
      throw Exception(_errorMessage);
    } on SocketException {
      _errorMessage = 'Tidak saat terhubung ke server';
      throw Exception(_errorMessage);
    } on PlatformException catch (e) {
      dev.log('Akses Google ditolak: $e');
      _errorMessage = 'Akses Google ditolak: ${e.message}';
      throw Exception(_errorMessage);
    } catch (e) {
      dev.log('Google Login Error: $e');
      _errorMessage = 'Gagal login Google';
      throw Exception(_errorMessage);
    }
  }

  // Update Profile (name, email, photoUrl) ke local user + storage
  Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(name: name, email: email, photoUrl: photoUrl);
    notifyListeners();

    // Update juga ke SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (name != null) await prefs.setString('name', name);
      if (email != null) await prefs.setString('email', email);
      // if (photoUrl != null) await prefs.setString('photoUrl', photoUrl);
      if (photoUrl != null) {
        await prefs.setString('photoUrl', photoUrl);
        profileImageNotifier.value = photoUrl; // refresh UI
      }
    } catch (e) {
      dev.log('[ERROR] Failed to update profile in storage: $e');
    }
  }

  // fungsi logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final profileImage =
        prefs.getString('profileImage') ??
        ''; // keep foto profile setelah logout

    await prefs.clear(); // clear all preferences

    if (profileImage.isNotEmpty) {
      await prefs.setString('profileImage', profileImage);
    }
    await _firebaseAuth.signOut(); // log out dari firebase
    await _googleSignIn.signOut(); // log out dari Google
    _user = null;
    notifyListeners();
  }

  // cek kondisi user (login atau tidak)
  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  // fungsi get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

      if (token != null) {
        _user = local.User(
          uid: uid ?? 0,
          firebase_id: firebase_id,
          name: name,
          email: email,
          token: token,
          photoUrl: photoUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      print('[ERROR] Gagal load dari penyimpanan: $e');
    }
  }

  // fetch user profile from backend API
  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        _user = null;
        notifyListeners();
        return;
      }

      final url = Uri.parse('$authEndpoint/profile');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming photoUrl is base64 encoded string from longblob
        String photoBase64 = data['photoUrl'] ?? '';
        _user = local.User(
          uid: data['uid'] ?? 0,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          token: token,
          photoUrl: photoBase64,
        );
        notifyListeners();

        // Update SharedPreferences with fresh data
        await prefs.setInt('uid', _user!.uid);
        await prefs.setString('name', _user!.name);
        await prefs.setString('email', _user!.email);
        await prefs.setString('photoUrl', photoBase64);
        profileImageNotifier.value = photoBase64;
      } else {
        print('[ERROR] Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] Exception in fetchUserProfile: $e');
    }
  }
}
