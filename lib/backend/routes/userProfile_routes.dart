import 'dart:convert';
import 'dart:io';
import 'package:abp_travel/backend/utils/constants/constants_server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:developer' as dev;
import '../services/user_services.dart';
import '../utils/helpers.dart';

class UserprofileRoutes {
  Router get router {
    final router = Router();

    // 🔹 Rute Get User Profile
    router.get('/user/profile', (Request req) async {
      final token = req.headers['Authorization']?.split(' ').last;
      final jwtData = verifyJWT(token);

      if (jwtData == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Akses ditolak'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final uid = jwtData['uid'].toString();

      try {
        final user = await UserServices.getUserbyId(uid);
        if (user == null) {
          return Response.notFound(
            jsonEncode({'error': 'User not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        return Response.ok(
          jsonEncode(user),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to get user profile: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 🔹 Rute Update User Profile
    router.put('/user/profile', (Request req) async {
      final token = req.headers['Authorization']?.split(' ').last;

      // cek token valid
      if (token == null || token.isEmpty) {
        return Response.forbidden(
          jsonEncode({'error': 'Token not found / not valid'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final jwtData = verifyJWT(token);

      if (jwtData == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Akses ditolak'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final uid = jwtData['uid'].toString();

      try {
        final body = await req.readAsString();
        final data = jsonDecode(body);

        if (data['name'] == null || data['email'] == null) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Nama dan Email harus diisi'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // validasi tambahan untuk ganti password
        if ((data['currentPassword'] != null || data['newPassword'] != null) &&
            (data['currentPassword'] == null || data['newPassword'] == null)) {
          return Response.badRequest(
            body: jsonEncode({'error': 'Password lama dan baru harus diisi'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // validasi panjang password(min. 8 karakter)
        if (data['currentPassword'] != null && data['newPassword'] != null) {
          if (data['newPassword'].length < 8) {
            return Response.badRequest(
              body: jsonEncode({'error': 'Password tidak valid'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }

        // Decode base64 jika ada foto
        String? photoUrl = data['photoUrl'];
        if (photoUrl != null) {
          try {
            // decode base64 => bytes
            final bytes = base64Decode(photoUrl);

            // // Tentukan batasan ukuran (misalnya 5MB)
            // if (bytes.length > 5 * 1024 * 1024) {
            //   // 5MB
            //   return Response.badRequest(
            //     body: jsonEncode({'error': 'File terlalu besar. Maksimal 5MB'}),
            //     headers: {'Content-Type': 'application/json'},
            //   );
            // }

            // lokasi penyimpanan foto
            final fileName = '${uid}_profile.jpg';
            final directory = Directory('profile_photos');
            if (!directory.existsSync()) {
              directory.createSync(
                recursive: true,
              ); // buat folder untuk save jika belum ada
            }
            final filePath = '${directory.path}/$fileName';
            File file = File(filePath);
            await file.writeAsBytes(bytes);

            // Update foto url yang dapat diakses
            final urlImage = '$userProfileEndpoint/profile/$fileName'; 
            photoUrl = urlImage;
          } catch (e) {
            return Response.badRequest(
              body: jsonEncode({'error': 'Gagal memproses foto: $e'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        }

        final updated = await UserServices.updateUserProfilebyId(
          uid,
          data['name']?.trim(),
          data['email']?.trim(),
          photoUrl,
          data['currentPassword']?.trim(),
          data['newPassword']?.trim(),
        );

        if (!updated) {
          return Response.internalServerError(
            body: jsonEncode({'error': 'Failed to update user profile'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.ok(
          jsonEncode({
            'message': 'User profile updated',
            'photoUrl': photoUrl ?? '',  
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        dev.log('Error in update profile: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to update user profile: $e'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
