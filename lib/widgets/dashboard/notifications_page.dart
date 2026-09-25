import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notifications_controller.dart';
import '../../models/notification.dart';
import '../../models/section.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
import 'overview_cards.dart' show OutlinedPill;
import 'section_states.dart';
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}
class _NotificationsPageState extends State<NotificationsPage> {
  NotificationsController get _ctrl => Get.find<NotificationsController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.load());
  }
  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return Obx(() {
      final section = _ctrl.page.value;
      final data = section.data;
      return RefreshIndicator(
        onRefresh: _ctrl.load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(gutter, 19, gutter, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (data != null && data.unread > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${data.unread} unread',
                        style: AppText.style(13, color: AppColors.textMuted),
                      ),
                    ),
                    OutlinedPill(
                      label: 'Mark all as read',
                      onTap: _ctrl.markAllRead,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              _NotificationBody(section: section),
            ],
          ),
        ),
      );
    });
  }
}
class _NotificationBody extends StatelessWidget {
  const _NotificationBody({required this.section});
  final Section<NotificationPage> section;
  @override
  Widget build(BuildContext context) {
    final data = section.data;
    if (data == null) {
      return section.isLoading
          ? const SectionLoading(height: 320)
          : SectionError(
              message: section.error ?? 'Could not load notifications.',
              onRetry: () =>
                  Get.find<NotificationsController>().load(),
              height: 120,
            );
    }
    if (data.items.isEmpty) {
      return const SectionEmpty(
        title: 'No notifications yet',
        message: 'Wallet top-ups and shipment updates will show up here.',
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < data.items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.rowDivider),
            _NotificationRow(notification: data.items[i]),
          ],
        ],
      ),
    );
  }
}
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});
  final AppNotification notification;
  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = _typeTone(notification.type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.find<NotificationsController>().markRead(notification),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(icon, size: 20, color: foreground),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.style(
                        14,
                        weight: notification.read ? 400 : 600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.style(
                        13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatRelativeTime(notification.createdAt!),
                        style: AppText.style(11, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: notification.read ? 'Read' : 'Unread',
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: notification.read
                        ? Colors.transparent
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  (Color, Color, AppIcons) _typeTone(String type) => switch (type) {
    'credit' => (const Color(0xFFE0FEDA), AppColors.success, AppIcons.arrowUp),
    'debit' => (const Color(0xFFFDE9E9), AppColors.error, AppIcons.arrowDown),
    'shipment' => (
        const Color(0xFFDEFCFE),
        const Color(0xFF479DA5),
        AppIcons.truck,
      ),
    'welcome' => (
        const Color(0xFFEDEFFB),
        AppColors.primary,
        AppIcons.invite,
      ),
    _ => (
        const Color(0xFFF3F4F6),
        AppColors.textMuted,
        AppIcons.notifications,
      ),
  };
}