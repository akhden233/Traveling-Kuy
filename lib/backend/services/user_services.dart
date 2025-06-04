import 'package:http/http.dart' as http;
import 'package:mysql1/mysql1.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import '../db/db.dart';
import '../utils/constants/constants_server.dart';
import '../utils/helpers.dart';

class UserServices {
  // Mendapatkan profil user
  static Future<Map<String, dynamic>> getUserProfile(
    String uid,
    String token,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('$userProfileEndpoint/profile'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(apiTO);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Mengupdate profil user
  static Future<bool> updateUserProfilebyId(
    String uid,
    String name,
    String email,
    String? photoUrl,
    String? currentPassword,
    String? newPassword,
  ) async {
    name = name.trim();
    email = email.trim();
    currentPassword = currentPassword?.trim();
    newPassword = newPassword?.trim();

    // connect db
    final conn = await dbConn.getConnection();
    if (conn == null) {
      throw Exception('Gagal terhubung ke Databse');
    }

    try {
      // start Transaction
      await conn.transaction((txn) async {
        // check email apakah ada duplikasi
        final checkEmail = await txn.query(
          'SELECT uid FROM users WHERE email = ? AND uid != ?',
          [email, uid],
        );

        if (checkEmail.isNotEmpty) {
          throw Exception('Email sudah digunakan oleh user lain');
        }

        // update name, email, photoUrl
        await txn.query(
          'UPDATE users SET name = ?, email = ?, photoUrl = ? WHERE uid = ?',
          [name, email, photoUrl ?? '', uid],
        );

        // get password from db
        if (currentPassword != null && newPassword != null) {
          final result = await txn.query(
            'SELECT pass FROM users WHERE uid = ?',
            [uid],
          );

          if (result.isEmpty) {
            throw Exception('User not found');
          }

          final currentHash = result.first['pass'] as String;
          final passCurrentHash = Helpers.hashedPass(currentPassword);

          if (currentHash != passCurrentHash) {
            throw Exception('Password lama salah');
          }

          // update password
          final newHash = Helpers.hashedPass(newPassword);
          await txn.query('UPDATE users SET pass = ? WHERE uid = ?', [
            newHash,
            uid,
          ]);
        }
      });

      return true;
    } catch (e) {
      dev.log('Failed to update user profile: $e');
      throw Exception('Failed to update user profile: $e');
    } finally {
      await conn.close();
    }
  }

  static Future<Map<String, dynamic>?> getUserbyId(String uid) async {
    var conn;
    try {
      conn = await dbConn.getConnection();

      final result = await conn!.query(
        'SELECT uid, name, email, photoUrl FROM users WHERE uid = ?',
        [uid],
      );

      if (result.isEmpty) return null;
      final row = result.first;
      return {
        'uid': row['uid'],
        'name': row['name'],
        'email': row['email'],
        'photoUrl': row['photoUrl'],
      };
    } catch (e) {
      dev.log('Failed to get user by ID :$e');
      throw Exception('Failed to get user by ID :$e');
    } finally {
      await conn.close();
    }
  }

  // // Mengirim permintaan reset password
  // static Future<void> requestPasswordReset(String email) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/user/password/reset-request'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({'email': email}),
  //     );

  //     if (response.statusCode != 200) {
  //       final data = jsonDecode(response.body);
  //       throw Exception(data['error'] ?? 'Failed to request password reset');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to connect to server: $e');
  //   }
  // }

  // // Reset password dengan token
  // static Future<void> resetPassword({
  //   required String token,
  //   required String newPassword,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/user/password/reset'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({
  //         'token': token,
  //         'newPassword': newPassword,
  //       }),
  //     );

  //     if (response.statusCode != 200) {
  //       final data = jsonDecode(response.body);
  //       throw Exception(data['error'] ?? 'Failed to reset password');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to connect to server: $e');
  //   }
  // }

  // // Menghapus akun
  // static Future<void> deleteAccount(String token) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$baseUrl/user/account'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       final data = jsonDecode(response.body);
  //       throw Exception(data['error'] ?? 'Failed to delete account');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to connect to server: $e');
  //   }
  // }
}
