import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../db/db.dart';
import 'package:dotenv/dotenv.dart';

class AuthServices {
  // load .env
  static final env = DotEnv()..load(['lib/backend/.env']);

  // Fungsi Register User
  static Future<bool> registerUser(
    String name,
    String email,
    String pass,
  ) async {
    final conn = await dbConn.getConnection();

    if (conn == null) {
      print("DB Connection failed.");
      return false;
    }

    try {
      var checkUser = await conn.query(
        'SELECT uid FROM users WHERE email = ?',
        [email],
      );
      if (checkUser.isNotEmpty) return false;

      var result = await conn.query(
        'INSERT INTO users (name, email, pass) VALUES (?, ?, SHA2(?, 256))',
        [name, email, pass],
      );
      return (result.affectedRows ?? 0) > 0;
    } catch (e) {
      print("Error saat registrasi ($email): $e");
      return false;
    } finally {
      await conn.close();
    }
  }

  // Fungsi Login User
  static Future<String?> loginUser(String email, String pass) async {
    final conn = await dbConn.getConnection(); // Pastikan pemanggilan benar

    try {
      var result = await conn?.query(
        'SELECT uid, name, email FROM users WHERE email = ? AND pass = SHA2(?, 256)',
        [email, pass],
      );

      if (result != null && result.isNotEmpty) {
        final secretKey =
            env['JWT_SECRET'] ??
            'b18ee2c67d22087c111cf77727034a0ee607d1448554131017c218abbf5b80c2';
        if (secretKey.isEmpty) {
          throw Exception("JWT_SECRET tidak ditemukan di .env");
        }

        final jwt = JWT({
          'uid': result.first['uid'],
          'name': result.first['name'],
          'email': result.first['email'],
        });
        return jwt.sign(SecretKey(secretKey));
      }
      return null;
    } catch (e) {
      print("Error saat login: $e");
      return null;
    } finally {
      await conn?.close();
    }
  }

  // Fungsi ambil User based on Email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final conn = await dbConn.getConnection();

    try {
      var result = await conn?.query(
        'SELECT uid, name, email, photoUrl FROM users WHERE email = ?',
        [email],
      );

      if (result != null && result.isNotEmpty) {
        // Return photoUrl 
        var photoData = result.first['photoUrl'];
        String photoBase64 = '';
        if (photoData != null && photoData is String) {
          photoBase64 = photoData;

        }

        return {
          'uid': result.first['uid'],
          'name': result.first['name'],
          'email': result.first['email'],
          'photoUrl': photoBase64,
        };
      }
      return null;
    } catch (e) {
      print('ERROR saat GetUser: $e');
      return null;
    } finally {
      await conn?.close();
    }
  }

  static Future<bool> registerUserViaGoogle(
    String name,
    String email,
    String? photoUrl,
  ) async {
    // connect to db
    final conn = await dbConn.getConnection();
    if (conn == null) {
      print('dbConn failed');
      return false;
    }

    try {
      // check user terdaftar
      final checkUser = await conn.query(
        'SELECT uid FROM users WHERE email = ?',
        [email],
      );
      if (checkUser.isNotEmpty) return false;

      // insert data baru
      final result = await conn.query(
        'INSERT INTO users (name, email, photoUrl) VALUES (?, ?, ?)',
        [name, email, photoUrl ?? ''],
      );

      return (result.affectedRows ?? 0) > 0;
    } catch (e) {
      print('Error saat registrasi dengan Google($email): $e');
      return false;
    } finally {
      await conn.close();
    }
  }
}
