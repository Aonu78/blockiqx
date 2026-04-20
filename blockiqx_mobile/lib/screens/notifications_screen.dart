import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:blockiqx/providers/auth_provider.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final isLoading = context.watch<NotificationProvider>().isLoading;
    final token = context.read<AuthProvider>().token;

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
      body: RefreshIndicator(
        onRefresh: () => context.read<NotificationProvider>().refresh(),
        child: notifications.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                children: [
                  Icon(
                    isLoading ? Icons.sync : Icons.notifications_none,
                    size: 52,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet. New report events and status updates will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final data = item.data;
                  final read = item.isRead;
                  final title = data['title'] as String? ?? 'Report update';
                  final message = data['message'] as String? ?? '';
                  final createdAt = _formatNotificationTime(item.createdAt);

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: Colors.white,
                    leading: CircleAvatar(
                      backgroundColor:
                          read ? Colors.grey.shade300 : Colors.blue.shade700,
                      child: Icon(
                        read
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(message),
                    ),
                    trailing: Text(
                      createdAt,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () async {
                      if (!read && token != null) {
                        await context
                            .read<NotificationProvider>()
                            .markAsRead(token, item.id);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  String _formatNotificationTime(String raw) {
    if (raw.isEmpty) return '';

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    return DateFormat('dd MMM\nhh:mm a').format(parsed.toLocal());
  }
}
