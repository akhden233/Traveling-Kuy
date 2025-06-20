import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:mysql1/mysql1.dart' show Blob;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf_static/shelf_static.dart';
import '../backend/middleware/middleware.dart';
import '../backend/routes/order_route.dart';
import 'db/db.dart';
import '../backend/utils/helpers.dart';
// import '../backend/auth/login_facebook_handler.dart';
import 'auth/auth_Google_Handler.dart';

void main() async {
  final env = DotEnv()..load(['lib/backend/.env']);

  try {
    print('Starting server...');
    print('[SUCCESS] Environment loaded');

    final jwtSecret =
        env['JWT_SECRET'] ??
        'b18ee2c67d22087c111cf77727034a0ee607d1448554131017c218abbf5b80c2';
    final port = int.tryParse(env['PORT'] ?? '5000') ?? 5000;

    print('Environment loaded. Port: $port');

    final router = Router();

    // Endpoint test
    router.get('/', (Request request) {
      print('[GET] / - Health check');
      final file = File('build/web/index.html');
      // return Response.ok("Backend Running!");
      return Response.ok(file.readAsStringSync(),
      headers: {'Content-Type': 'text/html'});
    });

    router.post('/auth/google', authGoogleHandler);
    // router.post('/auth/facebook', loginFBHandler);

    // Endpoint register
    router.post('/auth/register', (Request request) async {
      print('[POST] /auth/register - Registration attempt');
      var conn;

      try {
        print('[DEBUG] Attempting to connect to database...');

        conn = await dbConn.getConnection();
        if (conn == null) {
          print('[ERROR] Failed to connect to database');
          return Response.internalServerError(
            body: jsonEncode({'error': 'Database connection failed'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }
        print('[DEBUG] Database connection successful');

        final body = await request.readAsString();
        print('[DEBUG] Request body: $body');
        if (body.isEmpty) {
          print('[ERROR] Empty request body');
          return Response.badRequest(
            body: jsonEncode({'error': 'Request body kosong'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }
        final payload = jsonDecode(body);

        if (payload['name'] == null ||
            payload['email'] == null ||
            payload['pass'] == null) {
          print('[ERROR] Incomplete data');
          return Response.badRequest(
            body: jsonEncode({'error': 'Data tidak lengkap'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        // Validasi password
        if (payload['pass'].toString().length < 8) {
          print('[ERROR] Password too short');
          return Response.badRequest(
            body: jsonEncode({'error': 'Password harus minimal 8 karakter'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        // Hashing password
        final hashedPass =
            sha256.convert(utf8.encode(payload['pass'])).toString();

        try {
          // Check duplikasi email
          final checkDupe = await conn.query(
            'SELECT email FROM users WHERE email = ?',
            [payload['email']],
          );

          if (checkDupe.isNotEmpty) {
            return Response(
              409,
              body: jsonEncode({'error': 'Email sudah terdaftar'}),
              headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              },
            );
          }

          // input Email ke mysql
          await conn.query(
            'INSERT INTO users (name, email, pass) VALUES (?, ?, ?)',
            [payload['name'], payload['email'], hashedPass],
          );

          print('[SUCCESS] User registered: ${payload['email']}');
          return Response.ok(
            jsonEncode({'message': 'Registrasi Berhasil'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        } catch (dbError) {
          print('[ERROR] Database error: $dbError');
          throw dbError;
        }
      } catch (e, stackTrace) {
        print('[ERROR] Registration failed: $e\n$stackTrace');
        return Response.internalServerError(
          body: jsonEncode({'Terjadi kesalahan di server'}),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } finally {
        try {
          if (conn != null) {
            await conn.close();
          }
        } catch (e) {
          print('[ERROR] Gagal menutup koneksi: $e');
        }
      }
    });

    // Endpoint login dengan JWT
    router.post('/auth/login', (Request request) async {
      print('[POST] /login - Login attempt');
      print('[DEBUG] Request Headers: ${request.headers}');
      var conn;
      try {
        conn = await dbConn.getConnection();
        final body = await request.readAsString();
        print('[DEBUG] Request Body: $body');

        if (body.isEmpty) {
          print('[ERROR] Empty request body');
          return Response.badRequest(
            body: jsonEncode({'error': 'Request body kosong'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        final payload = jsonDecode(body);
        print('[DEBUG] Email: ${payload['email']}');
        print('[DEBUG] Pass: ${payload['pass']}');

        if (payload['email'] == null || payload['pass'] == null) {
          print('[ERROR] Incomplete data');
          return Response.badRequest(
            body: jsonEncode({'error': 'Data tidak lengkap'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        // Validasi password
        if (payload['pass'].toString().length < 8) {
          print('[ERROR] Password too short');
          return Response.badRequest(
            body: jsonEncode({'error': 'Password harus minimal 8 karakter'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        // Hashing password
        final hashedPass =
            sha256.convert(utf8.encode(payload['pass'])).toString();
        print('[DEBUG] Email: ${payload['email']}');
        print('[DEBUG] Hashed Password: $hashedPass');

        var results = await conn.query(
          'SELECT uid, name, photoUrl FROM users WHERE email = ? AND pass = ?',
          [payload['email'], hashedPass],
        );

        if (results != null && results.isNotEmpty) {
          final user = results.first;
          print('[SUCCESS] User found: ${user['name']}');

          // Get photoUrl as Blob and encode to base64 with prefix
          String photoBase64 = '';
          var photoData = user['photoUrl'];
          if (photoData != null) {
            if (photoData is Blob) {
              final bytes = photoData.toBytes();
              photoBase64 = 'data:image;base64,${base64Encode(bytes)}';
            } else if (photoData is Uint8List || photoData is List<int>) {
              photoBase64 = 'data:image;base64,${base64Encode(photoData)}';
            } else if (photoData is String) {
              photoBase64 = photoData;
            } else {
              print('[WARNING] Unknown photoUrl data type: ${photoData.runtimeType}');
              photoBase64 = '';
            }
          }
          print('[DEBUG] Foto Profile length: ${photoBase64.length}');
          print('[DEBUG] Foto Profile snippet: ${photoBase64.length > 30 ? photoBase64.substring(0, 30) : photoBase64}');

          // Generate JWT Token
          final jwt = JWT({
            'uid': user[0],
            'name': user[1],
            'email': payload['email'],
          });
          final token = jwt.sign(
            SecretKey(jwtSecret),
            expiresIn: Duration(days: 7),
          );

          return Response.ok(
            jsonEncode({
              'uid': user[0],
              'name': user[1],
              'email': payload['email'],
              'photoUrl': photoBase64,
              'token': token,
              'message': 'Login berhasil',
            }),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        } else {
          print('[ERROR] Invalid credentials for: ${payload['email']}');
          return Response.forbidden(
            jsonEncode({'message': 'Email atau password salah'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }
      } catch (e, stackTrace) {
        print('[ERROR] Login failed: $e\n$stackTrace');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Gagal login: $e'}),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } finally {
        try {
          if (conn != null) {
            await conn.close();
          }
        } catch (e) {
          print('[ERROR] Gagal menutup koneksi: $e');
        }
      }
    });

    // Endpoint destinasi
    router.get('/destination/', (Request request) async {
      print('[GET] /destination - Fetching destinations');
      print('[DEBUG] Request Headers: ${request.headers}');

      var conn;

      try {
        conn = await dbConn.getConnection();
        if (conn == null) {
          print('[ERROR] Koneksi db tidak tersedia');
          return Response.internalServerError(
            body: jsonEncode({'error': 'DB conn is null'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final results = await conn.query('SELECT * FROM destinations');

        if (results.isEmpty) {
          return Response.notFound(
            jsonEncode({'message': 'Destinations not found'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        List<Map<String, dynamic>> destinations = [];

        for (var row in results) {
          dynamic parsedPrice;
          try {
            var typePrice = row[7];

            if (typePrice is Blob) {
              final bytes = typePrice.toBytes();
              final jsonString = utf8.decode(bytes);
              parsedPrice = jsonDecode(jsonString);
            } else if (typePrice is Uint8List || typePrice is List<int>) {
              parsedPrice = jsonDecode(utf8.decode(typePrice));
            } else if (typePrice is String) {
              parsedPrice = jsonDecode(typePrice);
            } else {
              throw Exception("Tipe tidak sesuai: ${typePrice.runtimeType}");
            }
          } catch (e) {
            print('[ERROR] Gagal decode price: $e');
            parsedPrice = {};
          }

          Uint8List? bytes;
          final juicyBlob = row[2];

          if (juicyBlob is Uint8List) {
            bytes = juicyBlob;
          } else if (juicyBlob is List<int>) {
            bytes = Uint8List.fromList(juicyBlob);
          } else if (juicyBlob is Blob) {
            try {
              final blobBytes = juicyBlob.toBytes();
              bytes = Uint8List.fromList(blobBytes);
            } catch (e) {
              print('[ERROR] Gagal konversi Blob: $e');
              bytes = null;
            }
          } else {
            print(
              '[WARINING] Tipe file gambar tidak dikenal: ${juicyBlob.runtimeType}',
            );
          }

          String? imageBase64;

          if (bytes != null && bytes.isNotEmpty) {
            imageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
          } else {
            imageBase64 = null;
          }

          destinations.add({
            'destination_id': row[0] as int,
            'name': parseTextField(row[1]),
            'image_url': imageBase64,
            'address': parseTextField(row[3]),
            'latitude':
                row[4] is double ? row[4] : double.parse(row[4].toString()),
            'longitude':
                row[5] is double ? row[5] : double.parse(row[5].toString()),
            'description': parseTextField(row[6]),
            'price': parsedPrice,
            'is_active': (row[10] == 1),
          });

          print('[DEBUG] Tipe image_url: ${row[2].runtimeType}');
          print('[DEBUG] juicyBlob.runtimeType: ${juicyBlob.runtimeType}');
        }

        return Response.ok(
          jsonEncode({
            'message': 'Destinations fetched successfully',
            'data': destinations,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } catch (e, stackTrace) {
        print('[ERROR] Failed to fetch destinations: $e\n$stackTrace');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch destinations: $e'}),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } finally {
        try {
          if (conn != null) {
            await conn.close();
          }
        } catch (e) {
          print('[ERROR] Gagal menutup koneksi: $e');
        }
      }
    });

    // Endpoint untuk update profil pengguna
    router.put('/user/profile', (Request request) async {
      print('[PUT] /user/profile - Update user profile attempt');
      var conn;

      try {
        conn = await dbConn.getConnection();
        final body = await request.readAsString();

        if (body.isEmpty) {
          print('[ERROR] Empty request body');
          return Response.badRequest(
            body: jsonEncode({'error': 'Request body kosong'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        final payload = jsonDecode(body);
        print('[DEBUG] Payload received');

        final uid = payload['uid'];
        final name = payload['name']?.trim();
        final email = payload['email']?.trim();
        final currentPassword = payload['currentPassword']?.trim();
        final newPassword = payload['newPassword']?.trim();
        final photoUrl = payload['photoUrl'];

        if (uid == null || name == null || email == null) {
          print('[ERROR] data UID/Email/Name missing');
          return Response.badRequest(
            body: jsonEncode({'UID, Name, Email harus diisi'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        if (name == null || name.isEmpty) {
          print('[ERROR] Data Name missing');
          return Response.badRequest(
            body: jsonEncode({'error': 'Name tidak boleh kosong'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        if (email == null || email.isEmpty) {
          print('[ERROR] Data Email missing');
          return Response.badRequest(
            body: jsonEncode({'error': 'Email tidak boleh kosong'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        final checkEmail = await conn.query(
          'SELECT email FROM users WHERE email = ? AND uid != ?',
          [email, uid],
        );

        if (checkEmail.isNotEmpty) {
          print('[ERROR] Email sudah terdaftar');
          return Response(
            409,
            body: jsonEncode({'error': 'Email sudah terdaftar'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        final result = await conn.query(
          'SELECT pass FROM users WHERE uid = ?',
          [uid],
        );

        if (result.isEmpty) {
          print('[ERROR] User not Found');
          return Response(
            404,
            body: jsonEncode({'error': 'User not Found'}),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }

        final currentHash = result.first['pass'] as String;

        String? updatePass;
        if (newPassword != null && newPassword.isNotEmpty) {
          if (currentPassword == null || currentPassword.isEmpty) {
            print('[ERROR] current Password tidak diisi');
            return Response.badRequest(
              body: jsonEncode({'error': 'currentPassword harus diisi'}),
              headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              },
            );
          }
        }

        if (newPassword != null && newPassword.isNotEmpty) {
          final passHash = Helpers.hashedPass(currentPassword);
          if (passHash != currentHash) {
            print('[ERROR] Password lama salah');
            return Response(
              403,
              body: jsonEncode({'error': 'Password lama salah'}),
              headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              },
            );
          }
        }

        if (newPassword != null && newPassword.isNotEmpty) {
          if (newPassword.length < 8) {
            print('[ERROR] Password baru minimal 8 karakter');
            return Response.badRequest(
              body: jsonEncode({'error': 'Password baru minimal 8 karakter'}),
              headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              },
            );
          }
          updatePass = Helpers.hashedPass(newPassword);
        }

        Uint8List? photoByte;
        if (photoUrl != null && photoUrl.isNotEmpty) {
          try {
            final base64t =
                photoUrl.contains(',') ? photoUrl.split(',').last : photoUrl;
            photoByte = base64Decode(base64t);
            print(
              '[DEBUG] Photo decoded successfully, size: ${photoByte.length} bytes',
            );
          } catch (e) {
            dev.log('[ERROR] Gagal decode base64: $e');
            return Response.badRequest(
              body: jsonEncode({'error': 'Format photoUrl tidak valid'}),
              headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
              },
            );
          }
        }

        String sql;
        List<dynamic> params;

        if (updatePass != null && photoByte != null) {
          sql =
              'UPDATE users SET name = ?, email = ?, pass = ?, photoUrl = ? WHERE uid = ?';
          params = [name, email, updatePass, photoByte, uid];
        } else if (updatePass != null) {
          sql = 'UPDATE users SET name = ?, email = ?, pass = ? WHERE uid = ?';
          params = [name, email, updatePass, uid];
        } else if (photoByte != null) {
          sql =
              'UPDATE users SET name = ?, email = ?, photoUrl = ? WHERE uid = ?';
          params = [name, email, photoByte, uid];
        } else {
          sql = 'UPDATE users SET name = ?, email = ? WHERE uid = ?';
          params = [name, email, uid];
        }

        await conn.query(sql, params);

        print('[SUCCESS] User profile updated: $email');
        return Response.ok(
          jsonEncode({
            'message': 'Profil berhasil diperbarui',
            'photoUrl': photoUrl ?? '',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } catch (e, stackTrace) {
        print('[ERROR] Update profile failed: $e\n$stackTrace');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Gagal memperbarui profil: $e'}),
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } finally {
        try {
          if (conn != null) {
            await conn.close();
          }
        } catch (e) {
          print('[ERROR] Gagal menutup koneksi: $e');
        }
      }
    });

    router.mount('/order/', orderRouter().router);

    // Serve static files from build/web directory
    final staticHandler = createStaticHandler(
      'build/web',
      defaultDocument: 'index.html',
      serveFilesOutsidePath: true,
    );

    // Fallback handler to serve index.html for SPA routes
    Response fallbackHandler(Request request) {
      final indexFile = File('build/web/index.html');
      if (indexFile.existsSync()) {
        final contents = indexFile.readAsStringSync();
        return Response.ok(
          contents,
          headers: {
            'Content-Type': 'text/html',
            'Access-Control-Allow-Origin': '*',
          },
        );
      } else {
        return Response.notFound('Not Found');
      }
    }

    // Combine router and static file handler
    final handler = Pipeline()
        .addMiddleware(loggingMiddleware())
        .addMiddleware(corsMiddleware())
        .addHandler((Request request) async {
          // If request path starts with API routes, use router
          final path = request.url.path;
          if (path.startsWith('auth') ||
              path.startsWith('destination') ||
              path.startsWith('user') ||
              path.startsWith('order') ||
              path == '') {
            return router.call(request);
          }

          // Try to serve static file
          final staticResponse = await staticHandler(request);
          if (staticResponse.statusCode != 404) {
            return staticResponse;
          }

          // Fallback to index.html for SPA routing
          return fallbackHandler(request);
        });

    final server = await io.serve(handler, '0.0.0.0', port);
    print("✅ Server Running di http://${server.address.host}:${server.port}");
  } catch (e) {
    print('❌ Server failed to start: $e');
    exit(1);
  }
}
