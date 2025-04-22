// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../utils/constants.dart';
// import '../models/user_model.dart';

// class UserServices {
//   // Mendapatkan profil user
//   static Future<Map<String, dynamic>> getUserProfile(String token) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         return data;
//       } else {
//         throw Exception(data['error'] ?? 'Failed to get user profile');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to server: $e');
//     }
//   }

//   // Mengupdate profil user
//   static Future<Map<String, dynamic>> updateUserProfile({
//     required String token,
//     String? name,
//     String? email,
//     String? phone,
//     String? address,
//   }) async {
//     try {
//       final Map<String, dynamic> body = {};
//       if (name != null) body['name'] = name;
//       if (email != null) body['email'] = email;
//       if (phone != null) body['phone'] = phone;
//       if (address != null) body['address'] = address;

//       final response = await http.put(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         return data;
//       } else {
//         throw Exception(data['error'] ?? 'Failed to update user profile');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to server: $e');
//     }
//   }

//   // Mengubah password
//   static Future<void> changePassword({
//     required String token,
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/user/password'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'currentPassword': currentPassword,
//           'newPassword': newPassword,
//         }),
//       );

//       if (response.statusCode != 200) {
//         final data = jsonDecode(response.body);
//         throw Exception(data['error'] ?? 'Failed to change password');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to server: $e');
//     }
//   }

//   // Mengirim permintaan reset password
//   static Future<void> requestPasswordReset(String email) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/user/password/reset-request'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({'email': email}),
//       );

//       if (response.statusCode != 200) {
//         final data = jsonDecode(response.body);
//         throw Exception(data['error'] ?? 'Failed to request password reset');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to server: $e');
//     }
//   }

//   // Reset password dengan token
//   static Future<void> resetPassword({
//     required String token,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/user/password/reset'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'token': token,
//           'newPassword': newPassword,
//         }),
//       );

//       if (response.statusCode != 200) {
//         final data = jsonDecode(response.body);
//         throw Exception(data['error'] ?? 'Failed to reset password');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to server: $e');
//     }
//   }

//   // Menghapus akun
//   static Future<void> deleteAccount(String token) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/user/account'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode != 200) {
//         final data = jsonDecode(response.body);
//         throw Exception(data['error'] ?? 'Failed to delete account');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect to server: $e');
//     }
//   }
// } 