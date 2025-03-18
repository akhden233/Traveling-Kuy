import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

class Validators {
  static bool isVallidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  static bool isValidPassword(String pass) {
    return pass.length >= 16;
  }

  static bool isValidToken(String token) {
    final env = DotEnv()..load(['lib/backend/.env']);
    final secretKey = env['JWT_SECRET'] ?? 'secret_key';

    try {
      final jwt = JWT.verify(token, SecretKey(secretKey));
      return true; // Token valid
    } catch (e) {
      print("Token invalid: $e");
      return false; // Token tidak valid
    }
  }
}
