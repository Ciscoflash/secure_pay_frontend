import '../models/notification.dart';
import 'api_client.dart';
class NotificationService {
  NotificationService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<NotificationPage> notifications(String token) async {
    final envelope = await _client.get('/notifications', token: token);
    final items = envelope['data'];
    final meta = envelope['meta'];
    return NotificationPage(
      items: [
        if (items is List)
          for (final item in items.whereType<Map<String, dynamic>>())
            AppNotification.fromJson(item),
      ],
      unread: meta is Map<String, dynamic>
          ? (meta['unread'] as num?)?.toInt() ?? 0
          : 0,
    );
  }
  Future<void> markNotificationRead(String token, String id) async {
    await _client.post(
      '/notifications/${Uri.encodeComponent(id)}/read',
      const {},
      token: token,
    );
  }
  Future<void> markAllNotificationsRead(String token) async {
    await _client.post(
      '/notifications/read-all',
      const {},
      token: token,
    );
  }
}