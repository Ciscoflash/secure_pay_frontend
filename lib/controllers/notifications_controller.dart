import 'package:get/get.dart';
import '../models/notification.dart';
import '../models/section.dart';
import '../services/api_client.dart';
import '../services/notification_service.dart';
import 'authenticated_controller.dart';
class NotificationsController extends AuthenticatedController {
  NotificationsController({required this.service, required super.auth});
  final NotificationService service;
  final page = Rx<Section<NotificationPage>>(const Section.loading());
  int get unread => page.value.data?.unread ?? 0;
  @override
  void onInit() {
    super.onInit();
    load();
  }
  Future<void> load() async {
    page.value = Section.loading(page.value.data);
    try {
      page.value = Section.data(await authed(service.notifications));
    } on ApiException catch (error) {
      page.value = Section.error(error.message, page.value.data);
    }
  }
  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    _apply(
      (p) => p.copyWith(
        items: [
          for (final n in p.items)
            n.id == notification.id ? n.copyWith(read: true) : n,
        ],
        unread: (p.unread - 1).clamp(0, 1 << 31),
      ),
    );
    try {
      await authed(
        (token) => service.markNotificationRead(token, notification.id),
      );
    } on ApiException {
      load();
    }
  }
  Future<void> markAllRead() async {
    if (unread == 0) return;
    _apply(
      (p) => p.copyWith(
        items: [for (final n in p.items) n.copyWith(read: true)],
        unread: 0,
      ),
    );
    try {
      await authed(service.markAllNotificationsRead);
    } on ApiException {
      load();
    }
  }
  void _apply(NotificationPage Function(NotificationPage p) change) {
    final current = page.value.data;
    if (current == null) return;
    page.value = Section.data(change(current));
  }
}