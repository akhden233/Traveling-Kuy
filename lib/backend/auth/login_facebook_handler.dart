// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shelf/shelf.dart';
// import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:dotenv/dotenv.dart';
// import 'package:mysql1/mysql1.dart';
// import '../db/db.dart';

// final _env = DotEnv()..load(['lib/backend/.env']);

// String generateJWT(Map<String, dynamic> payload) {
//   final jwt = JWT(payload);

//   final token = jwt.sign(
//     SecretKey(_env['JWT_SECRET']!),
//     expiresIn: const Duration(days: 7),
//   );

//   return token;
// }

// Future<Response> loginFBHandler(Request request) async {
//   try {
//     final payload = await request.readAsString();
//     final data = jsonDecode(payload);
//     final token = data['token'];

//     if (token == null) {
//       return Response.badRequest(body: jsonEncode({'error': 'Missing token'}));
//     }

//     // Verifikasi token ke Graph API FB
//     final GraphFB = await http.get(
//       Uri.parse(
//         'https://graph.facebook.com/me?fields=id,name,email,picture.type(large)&access_token=$token',
//       ),
//     );

//     if (GraphFB.statusCode != 200) {
//       return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
//     }

//     final userInfo = jsonDecode(GraphFB.body);

//     final email = userInfo['email'] ?? '${userInfo['id']}@facebook.com';
//     final name = userInfo['name'];
//     final uid = userInfo['id'];
//     final photoUrl = userInfo['picture']['data']['url'];

//     final conn = await dbConn.getConnection();

//     // cek existing user
//     final hasil = await conn!.query('SELECT * FROM users WHERE uid = ?', [uid]);

//     int userId;

//     if (hasil.isEmpty) {
//       // Insert user baru
//       final insertHasil = await conn.query(
//         'INSERT INTO users (email, nama, uid, photoUrl) VALUES (?, ?, ?, ?)',
//         [email, name, uid, photoUrl],
//       );
//       userId = insertHasil.insertId!;
//     } else {
//       final row = hasil.first;
//       userId = row['id'];
//     }

//     final jwt = generateJWT({'id': userId, 'email': email, 'uid': uid});

//     return Response.ok(
//       jsonEncode({'token': jwt}),
//       headers: {'Content-Type': 'application/json'},
//     );
//   } catch (e) {
//     print('Login Facebook error: $e');
//     return Response.internalServerError(
//       body: jsonEncode({'error': 'Sometheng went wrong'}),
//     );
//   }
// }
