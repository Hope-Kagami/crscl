import 'package:flutter/material.dart';
import '../../core/database/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationRepository = NotificationRepository();
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await _notificationRepository.getNotifications();
    setState(() => _notifications = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification['id'].toString()),
            background: Container(color: Colors.red),
            onDismissed:
                (_) => _notificationRepository.markAsRead(notification['id']),
            child: ListTile(
              leading: Icon(
                notification['read'] ? Icons.mark_email_read : Icons.markunread,
                color:
                    notification['read']
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
              ),
              title: Text(notification['title']),
              subtitle: Text(notification['message']),
              trailing: Text(
                notification['created_at'].toString().split(' ')[0],
              ),
            ),
          );
        },
      ),
    );
  }
}
