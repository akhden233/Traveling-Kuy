import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/auth_services.dart';

class AuthRoutes {
  Router get router{
    final router = Router();

    // Rute Sign Up
    router.post('/register', (Request req) async{
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final success = await AuthServices.registerUser(data['name'], data['email'], data['pass']);
      return success ? Response.ok('User Terdaftar') :  Response.internalServerError();
    });

    // Rute Sign In
    router.post('/login', (Request req) async {
      final body = await req.readAsString();
      final data = jsonDecode(body);

      final token =  await AuthServices.loginUser(data['email'], data['pass']);
      return token != null ? Response.ok(jsonEncode({'token' : token})) : Response.forbidden('Invalid Credentials');
    });

    return router;
  }
}