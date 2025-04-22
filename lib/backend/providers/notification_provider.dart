
import 'package:flutter/material.dart' hide Notification;
import '../models/notification_model.dart' as models;
import '../services/notification_services.dart';

class NotificationProvider with ChangeNotifier {
  List<models.Notification> _notifications = [];
  bool _isLoading = false;
  String _error = '';
  int _unreadCount = 0;

  List<models.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadUserNotifications(String token) async{
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final notificationsData = await NotificationServices.getUserNotifications(token);
      _notifications = notificationsData.map((json) => models.Notification.fromJson(json)).toList();
      _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId, String token) async {
    try {
      await NotificationServices.markNotificationAsRead(notificationId, token);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          status: models.NotificationStatus.read,
        );
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId, String token) async {
    try {
      await NotificationServices.deleteNotification(notificationId, token);
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount(String token) async {
    try {
      _unreadCount = await NotificationServices.getUnreadNotificationCount(token);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => n.status == models.NotificationStatus.unread).length;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}