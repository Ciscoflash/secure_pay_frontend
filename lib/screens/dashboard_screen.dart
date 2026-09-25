import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notifications_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard/dashboard_home_page.dart';
import '../widgets/dashboard/nav_destination.dart';
import '../widgets/dashboard/notifications_page.dart';
import '../widgets/dashboard/page_header.dart';
import '../widgets/dashboard/placeholder_destination.dart';
import '../widgets/dashboard/sidebar.dart';
import '../widgets/dashboard/shipments_page.dart';
import '../widgets/dashboard/wallet_page.dart';
import 'routes.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  static const _sidebarBreakpoint = 1024.0;
  final _auth = Get.find<AuthController>();
  final _notifications = Get.find<NotificationsController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _destination = NavDestination.dashboard;
  @override
  void initState() {
    super.initState();
    if (!_auth.isVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Get.offAllNamed(Routes.verifyEmail);
      });
    }
  }
  Future<void> _logout() async {
    await _auth.logout();
    Get.offAllNamed(Routes.signIn);
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _sidebarBreakpoint;
        final sidebar = Obx(
          () => Sidebar(
            selected: _destination,
            firstName: _auth.user?.firstName ?? '',
            lastName: _auth.user?.lastName ?? '',
            unreadCount: _notifications.unread,
            onSelected: (destination) {
              setState(() => _destination = destination);
              if (destination == NavDestination.dashboard) {
                Get.find<DashboardController>().loadOverview();
              }
              if (!wide) Navigator.of(context).pop();
            },
            onLogout: _logout,
          ),
        );
        final page = Column(
          children: [
            PageHeader(
              title: _destination.pageTitle,
              subtitle: _destination.pageSubtitle,
              leading: wide
                  ? null
                  : IconButton(
                      tooltip: 'Open menu',
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                    ),
            ),
            Expanded(
              child: _content(
                constraints.maxWidth - (wide ? Sidebar.width : 0),
              ),
            ),
          ],
        );
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: wide ? null : Drawer(width: Sidebar.width, child: sidebar),
          body: wide
              ? Row(
                  children: [
                    sidebar,
                    Expanded(child: page),
                  ],
                )
              : page,
        );
      },
    );
  }
  Widget _content(double width) {
    switch (_destination) {
      case NavDestination.notifications:
        return const NotificationsPage();
      case NavDestination.wallet:
        return const WalletPage();
      case NavDestination.shipments:
        return const ShipmentsPage();
      case NavDestination.dashboard:
        return DashboardHomePage(width: width);
      default:
        return PlaceholderDestination(destination: _destination);
    }
  }
}