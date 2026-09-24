class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    this.createdAt,
  });
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime? createdAt;
  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    read: read ?? this.read,
    createdAt: createdAt,
  );
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        type: json['type']?.toString() ?? 'info',
        read: json['read'] == true,
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
      );
}
class NotificationPage {
  const NotificationPage({required this.items, required this.unread});
  final List<AppNotification> items;
  final int unread;
  NotificationPage copyWith({List<AppNotification>? items, int? unread}) =>
      NotificationPage(
        items: items ?? this.items,
        unread: unread ?? this.unread,
      );
}