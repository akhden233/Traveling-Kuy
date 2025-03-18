import 'package:dotenv/dotenv.dart';

class Config {
  static final _env = DotEnv()..load(['lib/backend/.env']);

  static String get secretKey => _env['JWT_SECRET'] ?? 'default_secret';
}
