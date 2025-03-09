import "dart:io";
import "package:shelf/shelf.dart";
import 'package:shelf/shelf_io.dart' as io;
import "package:shelf_router/shelf_router.dart";
import 'package:mysql1/mysql1.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() async {
  final router = Router();

  // endpoint test
  router.get('/', (Request request) {
    return Response.ok("Backend Running!");
  });

  // endpoint register
  router.post('/register', (Request request) async{
    final conn = await createConnection();
    final payload = await jsonDecode(await request.readAsString());

    // hashing
    final hashedPass = sha256.convert(utf8.encode(payload['pass'])).toString();

    await conn.query(
      'INSERT INTO users (name, email, pass) VALUES (?, ?, ?)',
      [payload['name'], payload['email'], hashedPass],
    );
    await conn.close(); // tutup conn mysql setelah digunakan

    return Response.ok(jsonEncode({'message': 'Registrasi Berhasil'}));
  });

  // endpoint login
  router.post('/login', (Request request) async{
    final conn =  await createConnection();
    final payload = jsonDecode(await request.readAsString());

    // Hash PASS
    final hashedPass = sha256.convert(utf8.encode(payload['pass'])).toString();

    var results = await conn.query(
      'SELECT uid, name FROM users WHERE email = ? AND pass =?',
      [payload['email'], hashedPass],
    );
    await conn.close(); // tutup conn mysql setelah digunakan

    final user = results.first;
    return Response.ok(jsonEncode({
      'uid': user[0],
      'name': user[1],
      'message': 'LogIn berhasil'
    }));
  });

  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addHandler(router);

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print("Server Running di http://${server.address.host}:${server.port}");
}

// Function connect to MySQL
Future<MySqlConnection> createConnection() async{
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'travelling_kuy',
    password: '',
  );
  return await MySqlConnection.connect(settings);
}