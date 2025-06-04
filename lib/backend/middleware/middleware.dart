import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../auth/token_verifier/verifier.dart';
import '../db/db.dart';
import '../middleware/booking_middleware.dart';
import '../middleware/payment_middleware.dart';
import '../routes/mainRouter.dart';

// Load .env
final env = DotEnv()..load(['lib/backend/.env']);


// header for CORS access
const Map<String, String> _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
  'Access-Control-Max-Age': '3600',
};

// middleware logging
Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      dev.log('[LOG] Request: ${request.method} ${request.requestedUri}');
      dev.log('[LOG] Headers: ${request.headers}');

      final response = await innerHandler(request);

      dev.log('[LOG] Response: ${response.statusCode}');
      return response;
    };
  };
}

// middleware Auth
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      var conn;

      if (request.method == 'OPTIONS') {
        return Response.ok('OPTIONS', headers: _corsHeaders);
      }

      // list endpoint yang tidak perlu autentikasi
      final publicEndpoints = [
        '/auth/register',
        '/auth/login',
        '/destinations/',
        '/destinations/popular',
      ];

      // Cek Public Endpoint
      final path = '/${request.url.pathSegments.join('/')}';
      final isPublicEndpoint = publicEndpoints.any((e) => path.startsWith(e));

      // Jika Public Endpoint = 1, maka lanjutkan
      if (isPublicEndpoint) {
        return innerHandler(request);
      }

      // Validasi Token untuk endpoint yang perlu autentikasi
      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'error': 'Unauthorized: Token required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      if (token.isEmpty) {
        return Response(
          401,
          body: jsonEncode({'error': 'Unauthorized: Invalid token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      try {
        // Connect DB
        conn = await dbConn.getConnection();

        // Decode token JWT LOKAL
        final jwtSecret = env['JWT_SECRET'];
        
        // cek token jwt
        if (jwtSecret == null) {
          throw Exception('JWT_SECRET is not set in .env file');
        }

        final jwt = JWT.verify(token, SecretKey(jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;

        final uid = payload['uid'].toString();
        final email = payload['email'];
        final name = payload['name'];

        if (uid.isEmpty) {
          throw Exception('Invalid JWT Token payload');
        }

        request = request.change(headers: {
          ...request.headers,
          'auth-type': 'local',
          'uid': uid,
          'email': email,
          'user_name': name,
        });
        dev.log('[AUTH] user: $uid ($email)');
        return innerHandler(request);
      } on JWTException catch(_) {
        return Response(
          401,
          body: jsonEncode({'error': 'Unauthorized: Token expired'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (_) {
        try {
          // Connect DB
          conn = await dbConn.getConnection();
          
          // Decode token Firebase untuk payload
          final tokenVerifier = FirebaseTokenVerifier();
          final claims = await tokenVerifier.verify(token);
          final firebase_id = claims['sub'] as String;
          final email = claims['email'];
          final name = claims['name'] ?? '';
          final photoUrl = claims['picture'] ?? '';

          // cek null uid
          if (firebase_id.isEmpty) {
            throw Exception('Missing UID on Firebase');
          }

          // cek akun terdaftar untuk cek firebase_id db;
          final result = await conn!.query(
            'SELECT uid FROM users WHERE firebase_id = ?',
            [firebase_id],
          );

          if(result.isEmpty){
            return Response.forbidden(
              jsonEncode({'error': 'User not registered'}),
              headers: {'Content-Type': 'application/json'},  
            );
          }
          final uid = result.first['uid'];

          request = request.change(
            headers: {
              ...request.headers,
              'auth-type': 'google',
              'uid': uid.toString(),
              'firebase_id': firebase_id,
              'email': email,
              'user_name': name,
              'user_photo': photoUrl,
            },
          );
          dev.log('[DEBUG] Header after token injection: ${request.headers}');
          dev.log('[AUTH] user: $firebase_id ($email)');
          return innerHandler(request);
        } catch (e) {
          dev.log('[ERROR] Firebase Token validation failed: $e');
          dev.log('[DEBUG] Token: $token');
          return Response(
            401,
            body: jsonEncode({
              'error': 'Unauthorized: Invalid or expired token',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        } finally {
          if (conn != null) {
            await conn.close();
          }
        }
      }
    };
  };
}

// // middleware booking ticket
// Middleware bookingValidationMiddleware() {
//   return (Handler innerHandler) {
//     return (Request request) async {
//       if (request.method == 'POST' && request.url.path.contains('booking')) {
//         try {
//           final payload = await request.readAsString();
//           final bookingData = jsonDecode(payload);

//           try {
//             final visitDate = DateTime.parse(bookingData['visitDate']);
//             final numberOfVisitors = bookingData['numberOfVisitors'];
//             final destination = bookingData['destination'];

//             BookingMiddleware.validateBookingData(
//               visitDate: visitDate,
//               numberOfVisitors: numberOfVisitors,
//               destination: destination,
//             );
//           } catch (e) {
//             return Response.badRequest(
//               body: jsonEncode({'error': e.toString()}),
//               headers: {'Content-Type': 'application/json'},
//             );
//           }
//         } catch (e) {
//           return Response.badRequest(
//             body: jsonEncode({'error': e.toString()}),
//             headers: {'Content-Type': 'application/json'},
//           );
//         }
//       }
//       return innerHandler(request);
//     };
//   };
// }

// // middleware payment
// Middleware paymentValidationMiddleware() {
//   return (Handler innerHandler) {
//     return (Request request) async {
//       if (request.method == 'POST' && request.url.path.contains('payment')) {
//         try {
//           final payload = await request.readAsString();
//           final paymentData = jsonDecode(payload);

//           try {
//             final amount = paymentData['amount'];
//             final method = paymentData['method'];
//             final booking = paymentData['booking'];

//             PaymentMiddleware.validatePaymentData(
//               amount: amount,
//               method: method,
//               booking: booking,
//             );
//           } catch (e) {
//             return Response.badRequest(
//               body: jsonEncode({'error': e.toString()}),
//               headers: {'Content-Type': 'application/json'},
//             );
//           }
//         } catch (e) {
//           return Response.badRequest(
//             body: jsonEncode({'error': e.toString()}),
//             headers: {'Content-Type': 'application/json'},
//           );
//         }
//       }
//       return innerHandler(request);
//     };
//   };
// }

// middleware CORS
Middleware corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: Map<String, String>.from(_corsHeaders));
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: {...response.headers, ..._corsHeaders});
    },
  );
}

// combine middleware into server
Future<void> main() async {
  final port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;

  final handler = Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(corsMiddleware())
      .addMiddleware(authMiddleware())
      // .addMiddleware(bookingValidationMiddleware())
      // .addMiddleware(paymentValidationMiddleware())
      .addHandler(mainRouter.call);
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4 , port);
  print('Server running on http://${server.address.host}:${server.port}');
}
