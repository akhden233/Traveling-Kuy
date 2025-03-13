import 'dart:async';
import 'package:dotenv/dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../utils/validators.dart';

// header for CORS access
const Map<String, String> _corsHeaders = {
  'Access-Control-Allow-Origin' : '*',
  'Access-Control-Allow-Methods' : 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers' : 'Origin, Content-Type, Authorization',
};

// middleware logging
Middleware loggingMiddleware(){
  return (Handler innerHandler){
    return (Request request) async {
      print('[LOG] Request: ${request.method} ${request.requestedUri}');

      final response = await innerHandler(request);

      print('[LOG] Response: ${response.statusCode}');
      return response;
    };
  };
}

// middleware Auth
Middleware authMiddleware(){
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Unauthorized: Token required');
      }

      final token = authHeader.substring(7); // ambil token setelah 'bearer'
      if (!Validators.isValidToken(token)) {
        return Response.forbidden('Unauthorized: Invalid Token');
      }
      return innerHandler(request);
    };
  };
}

// middleware CORS
Middleware corsMiddleware(){
  return createMiddleware(
    requestHandler: (Request request){
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: Map<String, String>.from(_corsHeaders));
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(
        headers: {
          ...response.headers,
          ..._corsHeaders,
        },
      );
    },
  );
}

// combine middleware into server
Future<void> main() async {
  final env = DotEnv()..load();
  final port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;

  final handler = Pipeline()
    .addMiddleware(loggingMiddleware())
    .addMiddleware(corsMiddleware())
    .addMiddleware(authMiddleware())
    .addHandler((Request request){
      return Response.ok('Hello, Middleware', headers: {'Content-Type': 'text/plain'});
    });
    final server = await shelf_io.serve(handler, 'localhost', 8080);
    print('Server running on http://${server.address.host}:${server.port}');
  }