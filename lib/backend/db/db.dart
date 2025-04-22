import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart';
import '../utils/helpers.dart';

final env = DotEnv()..load(['lib/backend/.env']);

class dbConn {
  static final dbConn _instance = dbConn._internal();
  static MySqlConnection? _connection;

  factory dbConn() {
    return _instance;
  }

  dbConn._internal();

  static Future<MySqlConnection?> getConnection() async {
    try {
      // get db config (.env)
      final host = env['DB_HOST'] ?? 'localhost';
      final port = int.parse(env['DB_PORT'] ?? '3306');
      final user = env['DB_USER'] ?? 'root';
      final db = env['DB_NAME'] ?? 'travelling_kuy';
      // final password = env['DB_PASS']?.trim() ?? '';

      _connection = await MySqlConnection.connect(
        ConnectionSettings(
          host: host,
          port: port,
          user: user,
          db: db,
          // password: password,
        ),
      ).timeout(const Duration(seconds: 10));
      
      print('[DEBUG] Success to connect to DB');
      return _connection;
    } catch (e) {
      print('[ERROR] Failed to connect to DB: $e');
      return null;
    }
  }

  // Closed Conn jika tidak digunakan
  static Future<void> closeConn() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null; // reset koneksi setelah di close
    }
  }

  // Insert ke tabel destination
  static Future<void> InsertDestination(
    List<Map<String, String>> destination,
  ) async {
    final conn = await getConnection();
    if (conn == null) {
      print('[ERROR] connection failed');
      return;
    }

    for (var destinationData in destination) {
      try {
        // destinationData
        final name = destinationData['title']!;

        // ubah file image ke blob
        final imagePath = destinationData['image']!;
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          print('[ERROR] Image file not found: $imagePath');
          continue;
        }
        final image_url = await imageFile.readAsBytes().timeout(
          Duration(seconds: 5),
        );

        // Max img size 10 MB
        // final image_url = await imageFile.openRead().take(10 * 1024 * 1024).toList();

        final address = destinationData['address']!;

        final price = {
          "Only-Ticket": safeParsePrice(destinationData['price_ticket_only']),
          "Package": safeParsePrice(destinationData['price_package']),
        };
        final description = destinationData['description'] ?? '';
        final latitude = 0.0;
        final longitude = 0.0;

        // SQL Query
        final query = '''
          INSERT INTO destinations (name, image_url, address, price, description, latitude, longitude, is_active, created_at, updated_at) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''';

        // run query
        await conn.query(query, [
          name,
          image_url,
          address,
          jsonEncode(price),
          description,
          latitude,
          longitude,
          1,
          DateTime.now().toIso8601String(),
          DateTime.now().toIso8601String(),
        ]);
        print('[DEBUG] Destination "$name" inserted succesfully');
      } catch (e, stackTrace) {
        print('[ERROR] Failed to insert destination: $e\n$stackTrace');
        rethrow;
      }
    }
  }
}
