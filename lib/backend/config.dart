import 'package:dotenv/dotenv.dart';

final env = DotEnv()..load(['lib/backend/.env']);
class Config {
  static String get secretKey => env['JWT_SECRET'] ?? 'default_secret';
}

const String midtransServerKey = 'YOUR_MIDTRANS_SERVER_KEY';
const String midtransClientKey = 'YOUR_MIDTRANS_CLIENT_KEY';
const String midtransApiUrl = 'https://api.sandbox.midtrans.com/v2';