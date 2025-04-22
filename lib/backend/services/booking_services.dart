import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants/constants_server.dart';

class BookingServices {
  // Mendapatkan daftar booking user
  static Future<List<Map<String, dynamic>>> getUserBookings(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$bookingEndpoint/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to get bookings');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Membuat booking baru
  static Future<Map<String, dynamic>> createBooking({
    required String destinationId,
    required DateTime visitDate,
    required int numberOfVisitors,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(bookingEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'destinationId': destinationId,
          'visitDate': visitDate.toIso8601String(),
          'numberOfVisitors': numberOfVisitors,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Membatalkan booking
  static Future<void> cancelBooking(String bookingId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$bookingEndpoint/$bookingId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? 'Failed to cancel booking');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Memodifikasi booking
  static Future<Map<String, dynamic>> modifyBooking({
    required String bookingId,
    required DateTime visitDate,
    required int numberOfVisitors,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$bookingEndpoint/$bookingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'visitDate': visitDate.toIso8601String(),
          'numberOfVisitors': numberOfVisitors,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to modify booking');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}