import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'app_icon.dart';
import 'nav_destination.dart';
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onLogout,
    this.firstName = '',
    this.lastName = '',
    this.unreadCount = 0,
  });
  static const width = 237.0;
  static const headerHeight = 93.0;
  final NavDestination selected;
  final ValueChanged<NavDestination> onSelected;
  final VoidCallback onLogout;
  final String firstName;
  final String lastName;
  final int unreadCount;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(27, 39, 29, 0),
                  sliver: SliverList.separated(
                    itemCount: NavDestination.values.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9.5),
                    itemBuilder: (context, i) {
                      final destination = NavDestination.values[i];
                      return _NavItem(
                        label: destination.label,
                        icon: destination.icon,
                        selected: destination == selected,
                        badge: destination == NavDestination.notifications
                            ? unreadCount
                            : 0,
                        onTap: () => onSelected(destination),
                      );
                    },
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(27, 48, 29, 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileTile(firstName: firstName, lastName: lastName),
                        const SizedBox(height: 22),
                        _NavItem(
                          label: 'Logout',
                          icon: AppIcons.logout,
                          selected: false,
                          onTap: onLogout,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });
  final String label;
  final AppIcons icon;
  final bool selected;
  final VoidCallback onTap;
  final int badge;
  @override
  State<_NavItem> createState() => _NavItemState();
}
class _NavItemState extends State<_NavItem> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final foreground = widget.selected
        ? Colors.white
        : _hovered
        ? AppColors.textPrimary
        : AppColors.textSecondary;
    final background = widget.selected
        ? AppColors.navy
        : _hovered
        ? const Color(0xFFF5F5F5)
        : Colors.transparent;
    return Semantics(
      button: true,
      selected: widget.selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                AppIcon(widget.icon, color: foreground),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.style(
                      16,
                      weight: widget.selected ? 500 : 400,
                      color: foreground,
                    ),
                  ),
                ),
                if (widget.badge > 0) ...[
                  const SizedBox(width: 8),
                  Semantics(
                    label: '${widget.badge} unread notifications',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? Colors.white
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.badge > 99 ? '99+' : '${widget.badge}',
                        style: AppText.style(
                          11,
                          weight: 600,
                          color: widget.selected
                              ? AppColors.error
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.firstName, required this.lastName});
  final String firstName;
  final String lastName;
  String get _initials {
    final letters = [
      for (final part in [firstName, lastName])
        if (part.trim().isNotEmpty) part.trim()[0].toUpperCase(),
    ];
    return letters.isEmpty ? '?' : letters.join();
  }
  @override
  Widget build(BuildContext context) {
    final style = AppText.style(
      14,
      color: AppColors.textSecondary,
      height: 1.6,
    );
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 49,
              height: 49,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials,
                style: AppText.style(16, weight: 600, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final name in [firstName, lastName])
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
