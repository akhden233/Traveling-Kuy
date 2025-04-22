import 'package:dotenv/dotenv.dart';

final env = DotEnv()..load(['lib/backend/.env']);
class Config {
  static String get secretKey => env['JWT_SECRET'] ?? 'default_secret';
}
