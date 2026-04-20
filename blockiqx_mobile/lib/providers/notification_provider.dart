import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

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
  HttpClient? _streamClient;
  HttpClientRequest? _streamRequest;
  HttpClientResponse? _streamResponse;
  StreamSubscription<String>? _streamSubscription;
  String? _activeToken;
  String? _lastNotificationCreatedAt;
  bool _connecting = false;
  bool _hasBootstrapped = false;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    NotificationService.instance.initialize();
  }

  Future<void> syncAuth(String? token) async {
    final normalizedToken = (token != null && token.isNotEmpty) ? token : null;

    if (_activeToken == normalizedToken) {
      return;
    }

    _activeToken = normalizedToken;

    if (_activeToken == null) {
      await stopRealtime();
      _notifications = [];
      _lastNotificationCreatedAt = null;
      _hasBootstrapped = false;
      notifyListeners();
      return;
    }

    await _restartRealtime();
  }

  Future<void> _restartRealtime() async {
    await stopRealtime(clearToken: false);
    final token = _activeToken;
    if (token == null) return;

    await _fetchNotifications(token, silent: true);
    _startPollingFallback(token);
    unawaited(_connectToStream(token));
  }

  void _startPollingFallback(String token) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _fetchNotifications(token, silent: true);
    });
  }

  Future<void> stopRealtime({bool clearToken = true}) async {
    _pollingTimer?.cancel();
    _pollingTimer = null;

    await _streamSubscription?.cancel();
    _streamSubscription = null;

    try {
      await _streamRequest?.close();
    } catch (_) {}

    _streamRequest = null;
    _streamResponse = null;

    _streamClient?.close(force: true);
    _streamClient = null;
    _connecting = false;

    if (clearToken) {
      _activeToken = null;
    }
  }

  Future<void> _connectToStream(String token) async {
    if (_connecting) return;
    _connecting = true;

    try {
      final uri = Uri.parse(ApiConfig.notificationStream).replace(
        queryParameters: _lastNotificationCreatedAt == null
            ? null
            : {'last_created_at': _lastNotificationCreatedAt!},
      );

      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Notification stream failed with status ${response.statusCode}',
          uri: uri,
        );
      }

      _streamClient = client;
      _streamRequest = request;
      _streamResponse = response;

      _streamSubscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        _handleStreamLine,
        onError: (_) => _scheduleReconnect(token),
        onDone: () => _scheduleReconnect(token),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect(token);
    } finally {
      _connecting = false;
    }
  }

  void _handleStreamLine(String line) {
    if (!line.startsWith('data:')) return;

    final payload = line.substring(5).trim();
    if (payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return;

      final item = NotificationItem.fromJson(decoded);
      _lastNotificationCreatedAt = item.createdAt;

      final existingIndex = _notifications.indexWhere((n) => n.id == item.id);
      if (existingIndex == -1) {
        _notifications = [item, ..._notifications];
        notifyListeners();

        final title = item.data['title']?.toString() ?? 'Notification';
        final body = item.data['message']?.toString() ?? '';
        unawaited(
          NotificationService.instance.showNotification(title: title, body: body),
        );
      } else {
        _notifications[existingIndex] = item;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _scheduleReconnect(String token) {
    if (_activeToken != token) return;

    _streamSubscription?.cancel();
    _streamSubscription = null;
    _streamClient?.close(force: true);
    _streamClient = null;
    _streamRequest = null;
    _streamResponse = null;

    Future.delayed(const Duration(seconds: 3), () {
      if (_activeToken == token) {
        unawaited(_connectToStream(token));
      }
    });
  }

  Future<void> refresh() async {
    final token = _activeToken;
    if (token == null) return;
    await _fetchNotifications(token);
  }

  Future<void> _fetchNotifications(String token, {bool silent = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (!silent) {
      notifyListeners();
    }

    try {
      final data = await ApiService.getNotifications(token);
      final List<dynamic> notificationsJson = data['notifications'] ?? [];
      final newNotifications = notificationsJson
          .map((json) => NotificationItem.fromJson(json))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final previousIds = _notifications.map((n) => n.id).toSet();
      _notifications = newNotifications;
      if (_notifications.isNotEmpty) {
        _lastNotificationCreatedAt = _notifications.first.createdAt;
      }

      if (_hasBootstrapped) {
        for (final item in newNotifications) {
          if (!previousIds.contains(item.id)) {
            final title = item.data['title']?.toString() ?? 'Notification';
            final body = item.data['message']?.toString() ?? '';
            unawaited(
              NotificationService.instance.showNotification(title: title, body: body),
            );
          }
        }
      }
      _hasBootstrapped = true;

      notifyListeners();
    } catch (e) {
      // Handle error silently or log
    } finally {
      _isLoading = false;
      if (!silent) {
        notifyListeners();
      }
    }
  }

  Future<void> markAsRead(String token, String notificationId) async {
    try {
      await ApiService.markNotificationRead(token, notificationId);

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
    stopRealtime();
    super.dispose();
  }
}
