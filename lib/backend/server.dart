import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() async {
  final env = DotEnv()..load(['lib/backend/.env']);

  final dbHost = env['DB_HOST'] ?? 'localhost';
  final dbPort = int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306;
  final dbUser = env['DB_USER'] ?? 'root';
  final dbPass = env['DB_PASS'] ?? '';
  final dbName = env['DB_NAME'] ?? 'travelling_kuy';
  final jwtSecret = env['JWT_SECRET'] ?? 'secret_key'; // Secret untuk JWT

  final router = Router();

  // Endpoint test
  router.get('/', (Request request) {
    return Response.ok("Backend Running!");
  });

  // Endpoint register
  router.post('/register', (Request request) async {
    try {
      final conn = await createConnection(dbHost, dbPort, dbUser, dbPass, dbName);
      final payload = jsonDecode(await request.readAsString());

      // Hashing password
      final hashedPass = sha256.convert(utf8.encode(payload['pass'])).toString();

      await conn.query(
        'INSERT INTO users (name, email, pass) VALUES (?, ?, ?)',
        [payload['name'], payload['email'], hashedPass],
      );
      await conn.close(); 

      return Response.ok(jsonEncode({'message': 'Registrasi Berhasil'}), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Gagal registrasi: $e'}));
    }
  });

  // Endpoint login dengan JWT
  router.post('/login', (Request request) async {
    try {
      final conn = await createConnection(dbHost, dbPort, dbUser, dbPass, dbName);
      final payload = jsonDecode(await request.readAsString());

      final hashedPass = sha256.convert(utf8.encode(payload['pass'])).toString();

      var results = await conn.query(
        'SELECT uid, name FROM users WHERE email = ? AND pass = ?',
        [payload['email'], hashedPass],
      );
      await conn.close(); 

      if (results.isNotEmpty) {
        final user = results.first;

        // Generate JWT Token
        final jwt = JWT({'uid': user[0], 'name': user[1]});
        final token = jwt.sign(SecretKey(jwtSecret), expiresIn: Duration(days: 7));

        return Response.ok(
          jsonEncode({
            'uid': user[0],
            'name': user[1],
            'token': token,
            'message': 'Login berhasil',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.forbidden(jsonEncode({'message': 'Email atau password salah'}));
      }
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': 'Gagal login: $e'}));
    }
  });

  // Middleware untuk log request
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print("✅ Server Running di http://${server.address.host}:${server.port}");
}

// Function untuk membuat koneksi ke MySQL
Future<MySqlConnection> createConnection(String host, int port, String user, String password, String dbName) async {
  try {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      db: dbName,
    );
    return await MySqlConnection.connect(settings);
  } catch (e) {
    print('❌ Error saat menghubungkan ke database: $e');
    throw Exception('Tidak bisa terhubung ke database');
  }
}
