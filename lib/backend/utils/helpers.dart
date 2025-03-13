import 'dart:convert';
import 'package:crypto/crypto.dart';

class Helpers {
  static String hashedPass(String pass) {
    return sha256.convert(utf8.encode(pass)).toString();
  }
}