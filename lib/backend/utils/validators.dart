import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../config.dart';

class Validators {
  static bool isVallidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  static bool isValidPassword(String pass){
    return pass.length >= 16;
  }

  static bool isValidToken(String token){
    try {
      final jwt = JWT.verify(token, SecretKey(Config.secretKey));
      final exp = jwt.payload['exp'];
      if (exp != null && DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp) {
        return false; // token expired
      }

      return true; // token valid
    } catch (e) {
      return false; // token tidak valid
    }
  }
}