import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No notifications yet. New report events and status updates will appear here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                final data = item['data'] as Map<String, dynamic>? ?? {};
                final read = item['read_at'] != null;
                final title = data['title'] as String? ?? 'Report update';
                final message = data['message'] as String? ?? '';
                final createdAt = item['created_at'] as String? ?? '';

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    backgroundColor: read ? Colors.grey.shade300 : Colors.blue.shade700,
                    child: Icon(
                      read ? Icons.notifications_none : Icons.notifications_active,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(message),
                  trailing: Text(
                    createdAt.isNotEmpty ? createdAt.split('T').first : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () async {
                    if (!read) {
                      await context.read<NotificationProvider>().markAsRead(item['id'].toString());
                    }
                  },
                );
              },
            ),
    );
  }
}
