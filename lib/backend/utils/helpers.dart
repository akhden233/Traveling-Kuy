import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mysql1/mysql1.dart';

// load .env
final env = DotEnv()..load(['lib/backend/.env']);

class Helpers {
  static String hashedPass(String pass) {
    return sha256.convert(utf8.encode(pass)).toString();
  }
}

// Parse tipe String yang terbaca sebagai blob
String parseTextField(dynamic field) {
  if (field is String) return field;
  if (field is Blob) return utf8.decode(field.toBytes());
  if (field is Uint8List || field is List<int>) return utf8.decode(field);
  return '';
}

// Parsing price
double safeParsePrice(String? priceString) {
  try {
    return double.parse(
      priceString?.replaceAll("Rp", "").replaceAll(".", "").trim() ?? "0",
    );
  } catch (_) {
    return 0.0;
  }
}

// verifikasi token dari firebase (frontend)
Future<Map<String, dynamic>?> verifyFirebaseToken(String idToken) async {
  final firebaseApiKey = env['FIREBASE_API_KEY'];

  final url = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$firebaseApiKey',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'idToken': idToken}),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    // check existing user
    if (decoded['users'] != null && decoded['users'].isNotEmpty) {
      return decoded['users']?.first; // info user
    } else {
      print('User tidak ditemukan dalam response firebase');
    }
  } else {
    print('Firebase token verification failed: ${response.body}');
  }
  return null;
}

Map<String, dynamic> decodeJWTHeader(String token) {
  try {
    final headerPart = token.split('.')[0];
    final normalized = base64Url.normalize(headerPart);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded) as Map<String, dynamic>;
  } catch (e) {
    print('Error decoding JWT Header: $e');
    throw Exception('Invalid JWT token format');
  }
}

Response generateJWT(Map<String, dynamic> payload) {
  try {
  final jwtClassified = env['JWT_SECRET'] ?? 'b18ee2c67d22087c111cf77727034a0ee607d1448554131017c218abbf5b80c2';
  if (jwtClassified.isEmpty) {
    throw Response.internalServerError(
      body: jsonEncode({'error': 'server configuration error'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final jwt = JWT(
    payload,
    issuer: 'abp-travel',
  );

  final token = jwt.sign(
    SecretKey(jwtClassified),
    expiresIn: const Duration(days: 7),
  );

  return Response.ok(
    jsonEncode({'token': token}),
    headers: {'Content-Type': 'application/json'},
  );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Gagal generate token: $e'}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}