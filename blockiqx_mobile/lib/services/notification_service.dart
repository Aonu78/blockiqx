import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pusher_client/pusher_client.dart';
import 'api_config.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<void> showNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'report_updates',
      'Report Updates',
      channelDescription: 'Updates for report events and status changes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  PusherClient createPusherClient() {
    final options = PusherOptions(
      cluster: ApiConfig.pusherCluster,
      encrypted: true,
    );

    final pusher = PusherClient(
      ApiConfig.pusherKey,
      options,
      enableLogging: false,
    );

    return pusher;
  }
}
