import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart';

class dbService {
  static final dbService _instance = dbService._internal();
  static MySqlConnection? _connection;

  factory dbService() {
    return _instance;
  }

  dbService._internal();

  static Future<MySqlConnection?> getConnection() async {
    if (_connection == null) {
      final env = DotEnv()..load();
      _connection = await MySqlConnection.connect(
        ConnectionSettings(
          host: env['DB_HOST']!,
          port: int.parse(env['DB_PORT']!),
          user: env['DB_USER']!,
          db: env['DB_NAME']!,
          password: env['DB_PASS']!,
        ),
      );
    }
    return _connection;
  }

  // Closed Conn jika tidak digunakan
  static Future<void> closeConn() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null; // reset koneksi setelah di close
    }
  }
}
