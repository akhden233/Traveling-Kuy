import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants/constants_server.dart';

class PaymentServices {
  // Mendapatkan daftar pembayaran user
  static Future<List<Map<String, dynamic>>> getUserPayments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$paymentEndpoint/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to get payments');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Membuat pembayaran baru
  static Future<Map<String, dynamic>> createPayment({
    required String bookingId,
    required String amount,
    required String paymentMethod,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$paymentEndpoint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'amount': amount,
          'paymentMethod': paymentMethod,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create payment');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // Mendapatkan status pembayaran
  static Future<Map<String, dynamic>> getPaymentStatus(String paymentId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$paymentEndpoint/$paymentId/status'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to get payment status');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
