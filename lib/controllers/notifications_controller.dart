import 'package:get/get.dart';

import '../models/notification.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import 'auth_controller.dart';
import 'dashboard_controller.dart' show Section;

/// Loads the user's notifications and tracks the unread count for the
/// sidebar badge. Readers refresh in place so the list never blanks.
class NotificationsController extends GetxController {
  NotificationsController(this._service, this._auth);

  final DashboardService _service;
  final AuthController _auth;

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
      page.value = Section.data(await _authed(_service.notifications));
    } on ApiException catch (e) {
      page.value = Section.error(e.message, page.value.data);
    }
  }

  /// Marks a single notification read optimistically. On failure the full
  /// list reloads so the badge and items stay truthful.
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
      await _authed(
        (token) => _service.markNotificationRead(token, notification.id),
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
      await _authed(_service.markAllNotificationsRead);
    } on ApiException {
      load();
    }
  }

  void _apply(NotificationPage Function(NotificationPage p) change) {
    final current = page.value.data;
    if (current == null) return;
    page.value = Section.data(change(current));
  }

  /// Runs [call] with the session token; a 401 ends the session.
  Future<T> _authed<T>(Future<T> Function(String token) call) async {
    final token = _auth.token;
    if (token == null) {
      await _auth.handleUnauthorized();
      throw ApiException('Please sign in again.', statusCode: 401);
    }
    try {
      return await call(token);
    } on ApiException catch (e) {
      if (e.statusCode == 401) await _auth.handleUnauthorized();
      rethrow;
    }
  }
}