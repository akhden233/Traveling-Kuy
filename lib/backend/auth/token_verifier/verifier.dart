import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'dart:developer' as dev;

class FirebaseTokenVerifier {
  // Load .env
  final env = DotEnv()..load(['lib/backend/.env']);

  static const _firebaseAuthUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=';

  // Firebase Project API Key from the .env
  String get _firebaseApiKey => env['FIREBASE_API_KEY'] ?? '';

  Future<Map<String, dynamic>> verify(String token) async {
    try {
      // Make the HTTP request to Firebase Auth token verification endpoint
      final response = await http.post(
        Uri.parse('$_firebaseAuthUrl$_firebaseApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': token}),
      );

      // Check if response is valid
      if (response.statusCode != 200) {
        dev.log('Firebase Token verification failed with status code: ${response.statusCode}');
        throw Exception('Firebase Token verification failed');
      }

      // Decode response
      final decodedResponse = jsonDecode(response.body);
      dev.log('Firebase response: $decodedResponse');

      // Ensure response contains valid claims
      if (decodedResponse['users'] == null || decodedResponse['users'].isEmpty) {
        throw Exception('Invalid token response from Firebase');
      }

      final claims = decodedResponse['users'][0];
      dev.log('Decoded Firebase claims: $claims');

      // Validate claims
      if (claims['sub'] == null || claims['sub'].toString().isEmpty) {
        throw Exception('Token does not have a valid "sub" claim (UID)');
      }

      if (claims['iss'] != 'https://securetoken.google.com/${env['FIREBASE_PROJECT_ID']}') {
        throw Exception('Invalid issuer');
      }

      if (claims['aud'] != env['FIREBASE_PROJECT_ID']) {
        throw Exception('Invalid audience');
      }

      final exp = claims['exp'];
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      if (expiry.isBefore(DateTime.now().subtract(Duration(seconds: 5)))) {
        throw Exception('Token expired');
      }

      return claims;
    } catch (e, stack) {
      dev.log('Error during token verification: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:jose/jose.dart' show JsonWebToken, JsonWebKey, JsonWebKeyStore;
// import 'package:dotenv/dotenv.dart';
// import 'package:abp_travel/backend/utils/helpers.dart';
// import 'dart:developer' as dev;

// abstract class TokenVerifier {
//   Future<Map<String, dynamic>> verify(String token);
// }

// // Token Verifier Firebase
// class FirebaseTokenVerifier implements TokenVerifier {
//   // Load .env
//   final env = DotEnv()..load(['lib/backend/.env']);

//   static const _firebaseKeyUrl =
//       'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

//   static final Map<String, JsonWebKey> _cachedKeys = {};
//   static DateTime _lastFetch = DateTime.now();

//   static const _duration = Duration(hours: 1);

//   Future<JsonWebKey> _getKey(String kid) async {
//     dev.log('Fetching key for kid: $kid');

//     if (_cachedKeys.containsKey(kid) && DateTime.now().isBefore(_lastFetch.add(_duration))) {
//       dev.log('Key found in cache for kid: $kid');
//       return _cachedKeys[kid]!;
//     }

//     final response = await http.get(Uri.parse(_firebaseKeyUrl));
//     dev.log(
//       'Fetching Firebase public keys, status code: ${response.statusCode}',
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Gagal untuk fetch Public Key Firebase');
//     }

//     final keysMap = json.decode(response.body) as Map<String, dynamic>;
//     dev.log('Fetched keys: ${keysMap.keys.toList()}');

//     keysMap.forEach((keyId, pem) {
//       dev.log('Caching key for kid: $keyId');
//       try {
//         final key = JsonWebKey.fromPem(pem);
//         _cachedKeys[keyId] = key;
//         dev.log('Cached keyId: $keyId');
//       } catch (e) {
//         dev.log('Failed to parse PEM for keyId: $keyId - $e');
//       }
//     });

//     _lastFetch = DateTime.now();

//     final key = _cachedKeys[kid];
//     if (key == null) {
//       throw Exception('Key ID tidak ditemukan');
//     }
//     return key;
//   }

//   @override
//   Future<Map<String, dynamic>> verify(String token) async {
//     try {
//       // Check token format
//       if (!token.contains('.')) {
//         throw Exception('Invalid token format');
//       }

//       final Header = decodeJWTHeader(token);
//       if (Header['kid'] == null) {
//         throw Exception('Invalid JWT header or missing kid');
//       }
//       dev.log('Decoded JWT Header: $Header');

//       final key = await _getKey(Header['kid']);
//       dev.log('Using key for kid: ${Header['kid']}');

//       // Verifying token signature
//       final keyStore = JsonWebKeyStore()..addKey(key);
//       final verifiedJwt = await JsonWebToken.decodeAndVerify(token, keyStore)
//       .catchError((e, stack) {
//         dev.log('JWT signature verification failed', error: e, stackTrace: stack,);
//         throw Exception('Token tidak valid: Signature verification gagal');
//       });
//       dev.log('Token signature verified successfully');

//       // Validate claims
//       final claims = verifiedJwt.claims.toJson();
//       dev.log('Token claims: $claims');

//       if (claims['sub'] == null || claims['sub'].toString().isEmpty) {
//         throw Exception('Token does not have sub(UID)');
//       }

//       if (claims['iss'] !=
//           'https://securetoken.google.com/${env['FIREBASE_PROJECT_ID']}') {
//         throw Exception('Invalid issuer');
//       }

//       if (claims['aud'] != env['FIREBASE_PROJECT_ID']) {
//         throw Exception('Invalid audience');
//       }

//       final exp = claims['exp'] as int;
//       final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
//       if (expiry.isBefore(DateTime.now().subtract(Duration(seconds: 5)))) {
//         throw Exception('Token expired');
//       }

//       return claims;
//     } catch (e, stack) {
//       dev.log('Error during token verification', error: e, stackTrace: stack);
//       rethrow; // rethrow the error for higher-level handling
//     }
//   }
// }
