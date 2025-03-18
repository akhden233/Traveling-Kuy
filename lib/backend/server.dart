import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mysql1/mysql1.dart';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../backend/middleware/middleware.dart';

void main() async {
  final env = DotEnv()..load(['lib/backend/.env']);
  print("[DEBUG] JWT_SECRET: ${env['JWT_SECRET']}");

  final dbHost = env['DB_HOST'] ?? 'localhost';
  final dbPort = int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306;
  final dbUser = env['DB_USER'] ?? 'root';
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
      final conn = await createConnection(dbHost, dbPort, dbUser, dbName);
      final body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Request body kosong'}),
        );
      }
      final payload = jsonDecode(body);

      if (payload['name'] == null ||
          payload['email'] == null ||
          payload['pass'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Data tidak lengkap'}),
        );
      }

      // Hashing password
      final hashedPass =
          sha256.convert(utf8.encode(payload['pass'])).toString();

      await conn.query(
        'INSERT INTO users (name, email, pass) VALUES (?, ?, ?)',
        [payload['name'], payload['email'], hashedPass],
      );
      await conn.close();

      return Response.ok(
        jsonEncode({'message': 'Registrasi Berhasil'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Gagal registrasi: $e'}),
      );
    }
  });

  // Endpoint login dengan JWT
  router.post('/login', (Request request) async {
  print('[LOG] /login endpoint accessed');
  try {
    final conn = await createConnection(dbHost, dbPort, dbUser, dbName);
    final body = await request.readAsString();
    if (body.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Request body kosong'}),
      );
    }
    final payload = jsonDecode(body);

    if (payload['email'] == null || payload['pass'] == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Data tidak lengkap'}),
      );
    }

    // Hashing password
    final hashedPass = sha256.convert(utf8.encode(payload['pass'])).toString();
    print('[DEBUG] Email: ${payload['email']}');
    print('[DEBUG] Hashed Password: $hashedPass');

    var results = await conn.query(
      'SELECT uid, name FROM users WHERE email = ? AND pass = ?',
      [payload['email'], hashedPass],
    );
    await conn.close();

    if (results.isNotEmpty) {
      final user = results.first;

      // Generate JWT Token
      final jwt = JWT({'uid': user[0], 'name': user[1]});
      final token = jwt.sign(
        SecretKey(jwtSecret),
        expiresIn: Duration(days: 7),
      );

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
      return Response.forbidden(
        jsonEncode({'message': 'Email atau password salah'}),
      );
    }
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': 'Gagal login: $e'}),
    );
  }
});

  // Middleware untuk log request
  final handler = Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(corsMiddleware())
      // .addMiddleware(authMiddleware())
      .addHandler(router.call);

  final server = await io.serve(handler, 'localhost', 8080);
  print("✅ Server Running di http://${server.address.host}:${server.port}");
}

// Function untuk membuat koneksi ke MySQL
Future<MySqlConnection> createConnection(
  String host,
  int port,
  String user,
  String dbName,
) async {
  try {
    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      db: dbName,
    );
    final conn = await MySqlConnection.connect(settings);
    print("✅ Connected to database");
    return conn;
  } catch (e) {
    print('❌ Error saat menghubungkan ke database: $e');
    throw Exception('Tidak bisa terhubung ke database');
  }
}
