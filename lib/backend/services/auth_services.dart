import 'package:mysql1/mysql1.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../db/db.dart'; 
import 'package:dotenv/dotenv.dart';

class AuthServices {
  // Fungsi Register User
  static Future<bool> registerUser(String name, String email, String pass) async {
    final conn = await dbService.getConnection();

    if (conn == null) {
      print("DB Connection failed.");
      return false;
    }

    try {
      var checkUser = await conn.query('SELECT uid FROM users WHERE email = ?', [email]);
      if (checkUser.isNotEmpty) return false;

      var result = await conn.query(
        'INSERT INTO users (name, email, pass) VALUES (?, ?, SHA2(?, 256))',
        [name, email, pass],
      );
      return (result.affectedRows ?? 0) > 0;
    } catch (e) {
      print("Error saat registrasi: $e");
      return false;
    } 
  }

  // Fungsi Login User
  static Future<String?> loginUser(String email, String pass) async {
    final conn = await dbService.getConnection(); // Pastikan pemanggilan benar
    final env = DotEnv()..load();

    try {
      var result = await conn?.query(
        'SELECT uid, name FROM users WHERE email = ? AND pass = SHA2(?, 256)',
        [email, pass],
      );

      if (result!.isNotEmpty) {
        final secretKey = env['JWT_SECRET'];
        if (secretKey == null) {
          throw Exception("JWT_SECRET tidak ditemukan di .env");
        }

        final jwt = JWT({'uid': result.first['uid'], 'name': result.first['name']});
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
}
