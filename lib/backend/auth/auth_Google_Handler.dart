import 'dart:convert';
import 'dart:developer' as dev;
import 'package:shelf/shelf.dart';
import '../auth/token_verifier/verifier.dart';
import '../utils/helpers.dart';
import '../db/db.dart';


Future<Response> authGoogleHandler(Request request) async {
  // Save userInfo ke DB
  var conn = await dbConn.getConnection();
  if (conn == null) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Koneksi Database Gagal'}),
    );
  }

  try {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);
    final token = data['token'];

    if (token == null || token.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing token'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Verifikasi token google di firebase
    final claims = await FirebaseTokenVerifier().verify(token);
    final firebase_id = claims['sub'];
    final email = claims['email'];
    final name = claims['name'] as String? ?? '';
    final photoUrl = claims['picture'] as String? ?? '';

    // cek existing user
    final checkUser = await conn.query(
      'SELECT * FROM users WHERE firebase_id = ? AND email = ?',
      [firebase_id, email],
    );

    if (checkUser.isNotEmpty) {
      return Response.badRequest(
        body: ({'error': 'Email sudah digunakan oleh akun lain'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    int uid;

    if (checkUser.isEmpty) {
      // Insert user baru => db
      await conn.query(
        'INSERT INTO users (firebase_id, email, name, photoUrl) VALUES (?, ?, ?, ?)',
        [firebase_id, email, name, photoUrl],
      );

      final result = await conn.query(
        'SELECT uid FROM users WHERE firebase_id = ?',
        [firebase_id],
      );
      uid = result.first['uid'];
      dev.log('User added into DB with uid: $uid');
    } else {
      uid = checkUser.first['uid'];
      dev.log('User found on db with uid: $uid');
    }

    // generate token JWT App
    final jwt = generateJWT({
      'uid': uid,
      'firebase_id': firebase_id,
      'email': email,
      'name': name,
    });

    // return response json => frontend
    return Response.ok(
      jsonEncode({
        'token': jwt,
        'user': {
          'uid': uid,
          'firebase_id': firebase_id,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
        },
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e, stack) {
    dev.log('Login GOOGLE error', error: e, stackTrace: stack, name: 'loginGoogleHandler');
    return Response.internalServerError(
      body: jsonEncode({
        'error': 'Something went wrong',
        'message': e.toString(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } finally {
    await conn.close();
  }
}
