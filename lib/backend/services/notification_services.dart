import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants/constants_server.dart';

class NotificationServices {
  // Get All notifikasi
  static Future<List<Map<String, dynamic>>> getUserNotifications(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$notificationEndpoint/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to Load Notifications');
      }
    } catch (e) {
      throw Exception('Failed to Connect to Server: $e');
    }
  }

  // Mark as Read notifikasi
  static Future<void> markNotificationAsRead(
    String token,
    String notificationId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$notificationEndpoint/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Failed to Connect to Server: $e');
    }
  }

  // Delete Notifikasi
  static Future<void> deleteNotification(
    String token,
    String notificationId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$notificationEndpoint/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(
          data['error'] ?? 'Failed to delete notification',
        );
      }
    } catch (e) {
      throw Exception('Failed to Connect to Server: $e');
    }
  }

  // Get notifikasi yang belum dibaca
  static Future<int> getUnreadNotificationCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$notificationEndpoint/unread'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['count'] as int;
      } else {
        throw Exception(data['error'] ?? 'Failed to get unread notification count');
      }
    } catch (e) {
      throw Exception('Failed to Connect to Server: $e');
    }
  }
}
