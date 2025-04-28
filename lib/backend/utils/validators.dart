import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

// load .env
final env = DotEnv()..load(['lib/backend/.env']);

class Validators {
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  static bool isValidPassword(String pass) {
    // minimal 8 karakter (huruf dan angka)
    return pass.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(pass) &&
        RegExp(r'[0-9]').hasMatch(pass);
  }

  static bool isValidToken(String token) {
    final secretKey = env['JWT_SECRET'];

    if (secretKey == null) {
      throw Exception('JWT_SECRET tidak ada di .env');
    }

    try {
      JWT.verify(token, SecretKey(secretKey));
      return true; // Token valid
    } catch (e) {
      print("Token invalid: $e");
      return false; // Token tidak valid
    }
  }
}
