import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_services.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // 🔹 Rute Sign Up
    router.post('/register', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        // Cek apakah data lengkap
        if (data['name'] == null || data['email'] == null || data['pass'] == null) {
          return Response.badRequest(body: jsonEncode({'error': 'Data tidak lengkap'}));
        }

        final success = await AuthServices.registerUser(data['name'], data['email'], data['pass']);
        return success
            ? Response.ok(jsonEncode({'message': 'User Terdaftar'}), headers: {'Content-Type': 'application/json'})
            : Response.internalServerError(body: jsonEncode({'error': 'Gagal registrasi'}));
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': 'Gagal memproses request: $e'}));
      }
    });

    // 🔹 Rute Sign In
    router.post('/login', (Request req) async {
      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        // Cek apakah data lengkap
        if (data['email'] == null || data['pass'] == null) {
          return Response.badRequest(body: jsonEncode({'error': 'Email dan password harus diisi'}));
        }

        final token = await AuthServices.loginUser(data['email'], data['pass']);
        return token != null
            ? Response.ok(jsonEncode({'token': token}), headers: {'Content-Type': 'application/json'})
            : Response.forbidden(jsonEncode({'error': 'Email atau password salah'}));
      } catch (e) {
        return Response.internalServerError(body: jsonEncode({'error': 'Gagal memproses request: $e'}));
      }
    });

    return router;
  }
}
