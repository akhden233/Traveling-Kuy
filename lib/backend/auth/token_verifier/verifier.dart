import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart' show JsonWebToken, JsonWebKey, JsonWebKeyStore;
import 'package:dotenv/dotenv.dart';
import 'package:abp_travel/backend/utils/helpers.dart';
import 'dart:developer' as dev;

abstract class TokenVerifier {
  Future<Map<String, dynamic>> verify(String token);
}

// Token Verifier Firebase
class FirebaseTokenVerifier implements TokenVerifier {
  // Load .env
  final env = DotEnv()..load(['lib/backend/.env']);


  static const _firebaseKeyUrl =
      'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

  static final _cachedKeys = <String, dynamic>{};

  Future<JsonWebKey> _getKey(String kid) async {
    if (_cachedKeys.containsKey(kid)) {
      return _cachedKeys[kid]!;
    }

    final response = await http.get(Uri.parse(_firebaseKeyUrl));
    if (response.statusCode != 200) {
      throw Exception('Gagal untuk fetch Public Key Firebase');
    }

    final keysMap = json.decode(response.body) as Map<String, dynamic>;
    keysMap.forEach((keyId, pem) {
      _cachedKeys[keyId] = JsonWebKey.fromPem(pem);
    });

    final key = _cachedKeys[kid];
    if (key == null) {
      throw Exception('Key ID tidak ditemukan');
    }
    return key;
  }

  @override
  Future<Map<String, dynamic>> verify(String token) async {
    try {
      final Header = decodeJWTHeader(token);
      final key = await _getKey(Header['kid']);

      // Verifikasi ttd token
      final keyStore = JsonWebKeyStore()..addKey(key);
      final verifiedJwt = await JsonWebToken.decodeAndVerify(token, keyStore);

      // Validasi claims
      final claims = verifiedJwt.claims.toJson();

      if (claims['sub'] == null || claims['sub'].toString().isEmpty) {
        throw Exception('Token tidak memiliki sub(UID)');
      }

      if (claims['iss'] !=
          'https://securetoken.google.com/${env['FIREBASE_PROJECT_ID']}') {
        throw Exception('Invalid issuer');
      }

      if (claims['aud'] != env['FIREBASE_PROJECT_ID']) {
        throw Exception('Invalid audience');
      }

      final exp = claims['exp'] as int;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (expiry.isBefore(DateTime.now().subtract(Duration(seconds: 5)))) {
        throw Exception('Token expired');
      }

      return claims;
    } catch (e, stack) {
      dev.log('Verifikasi token Firebase gagal:', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
