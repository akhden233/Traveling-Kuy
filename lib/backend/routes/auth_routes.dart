import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_services.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // 🔹 Rute Sign Up
    router.post('/auth/register', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        // Cek apakah data lengkap
        if (data['name'] == null ||
            data['email'] == null ||
            data['pass'] == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Data tidak lengkap'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (!Validators.isValidPassword(data['pass'])) {
          return Response.badRequest(
            body: jsonEncode({
              'error':
                  'Password minimal 8 karakter mengandung huruf kapital dan angka',
            }),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final success = await AuthServices.registerUser(
          data['name'],
          data['email'],
          data['pass'],
        );
        return success
            ? Response.ok(
              jsonEncode({'message': 'User Terdaftar'}),
              headers: {'Content-Type': 'application/json'},
            )
            : Response.internalServerError(
              body: jsonEncode({'error': 'Gagal registrasi'}),
              headers: {'Content-Type': 'application/json'},
            );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Gagal memproses request: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 🔹 Rute Sign In
    router.post('/auth/login', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        // Cek apakah data lengkap
        if (data['email'] == null || data['pass'] == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Email dan password harus diisi'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final token = await AuthServices.loginUser(data['email'], data['pass']);

        if (token == null) {
          return Response.forbidden(
            jsonEncode({'error': 'Email atau password salah'}),
          );
        }

        // get user by email
        final user = await AuthServices.getUserByEmail(data['email']);

        if (user == null) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'User not found'}),
          );
        }
        return Response.ok(
          jsonEncode({
            'token': token,
            'uid': user['uid'],
            'name': user['name'],
            'email': user['email'],
            'photoUrl': user['photoUrl'] ?? '',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Gagal memproses request: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // Route auth Google
    router.post('/auth/google', (Request request) async {
      try {
        final body = await request.readAsString();
        final data = jsonDecode(body);
        final idToken = data['idToken'];

        if (idToken == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'ID token tidak ditemukan'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final firebaseData = await verifyFirebaseToken(idToken);
        if (firebaseData == null) {
          return Response.forbidden(
            jsonEncode({'error': 'Google token tidak valid'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final email = firebaseData['email'];
        final name = firebaseData['name'] ?? 'Google User';
        final photoUrl = firebaseData['picture'] ?? '';

        if (email.isEmpty || !email.contains('@')) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Email Google tidak valid'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // check user di db
        var existingUser = await AuthServices.getUserByEmail(email);

        if (existingUser == null) {
          final newUser = await AuthServices.registerUserViaGoogle(
            name,
            email,
            photoUrl,
          );
          if (!newUser) {
            return Response.internalServerError(
              body: jsonEncode({'error': 'Gagal membuat akun baru'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }

        // ambil lagi data user
        final user = await AuthServices.getUserByEmail(email);

        // generate token apk => user
        final token = generateJWT(user!);

        return Response.ok(
          jsonEncode({
            'token': token,
            'uid': user['uid'],
            'email': user['email'],
            'name': user['name'],
            'photoUrl': user['photoUrl'],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Error: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });
    return router;
  }
}
