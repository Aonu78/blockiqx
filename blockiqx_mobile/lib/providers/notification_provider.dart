import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class NotificationItem {
  final String id;
  final Map<String, dynamic> data;
  final String createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      data: json['data'],
      createdAt: json['created_at'],
      isRead: json['read_at'] != null,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void startPolling(String token) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchNotifications(token);
    });
    _fetchNotifications(token); // Initial fetch
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchNotifications(String token) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService._httpClient.get(
        Uri.parse(ApiConfig.notifications),
        headers: ApiConfig.headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notificationsJson = data['notifications'] ?? [];
        final newNotifications = notificationsJson
            .map((json) => NotificationItem.fromJson(json))
            .toList();

        // Update only if there are changes
        if (!listEquals(_notifications, newNotifications)) {
          _notifications = newNotifications;
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error silently or log
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String token, String notificationId) async {
    try {
      await ApiService._httpClient.put(
        Uri.parse(ApiConfig.markNotificationRead(notificationId)),
        headers: ApiConfig.jsonHeaders(token),
      );

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: _notifications[index].id,
          data: _notifications[index].data,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

  bool _shouldReceive(Map<String, dynamic> report, List<dynamic>? target) {
    final user = _authProvider.user;
    final staff = _authProvider.staff;

    if (_authProvider.isAdmin) {
      return true;
    }

    if (_authProvider.isStaff) {
      if (report['assigned_to'] != null && report['assigned_to'].toString() == staff?.id.toString()) {
        return true;
      }
      return target?.contains('staff') == true;
    }

    if (_authProvider.isUser) {
      if (report['user_id'] != null && report['user_id'].toString() == user?.id.toString()) {
        return true;
      }
      return target?.contains('user') == true;
    }

    return false;
  }
}
