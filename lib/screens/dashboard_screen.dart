import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notifications_controller.dart';
import '../models/dashboard.dart';
import '../models/shipment.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/formatters.dart';
import '../widgets/dashboard/app_icon.dart';
import '../widgets/dashboard/dashboard_dialogs.dart';
import '../widgets/dashboard/growth_chart.dart';
import '../widgets/dashboard/notifications_page.dart';
import '../widgets/dashboard/overview_cards.dart';
import '../widgets/dashboard/page_header.dart';
import '../widgets/dashboard/promo_banner.dart';
import '../widgets/dashboard/section_states.dart';
import '../widgets/dashboard/shipment_card.dart';
import '../widgets/dashboard/sidebar.dart';
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
  final _dashboard = Get.find<DashboardController>();
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
  void _toast(String title, String message, {bool error = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      maxWidth: 480,
      margin: const EdgeInsets.all(16),
      backgroundColor: error ? const Color(0xFFFDECEC) : AppColors.surface,
      colorText: AppColors.textPrimary,
      borderColor: error ? AppColors.error : AppColors.outline,
      borderWidth: 1,
    );
  }
  Future<void> _fundWallet() async {
    final funded = await showFundWalletDialog(
      context,
      onSubmit: _dashboard.fundWallet,
    );
    if (funded != null) {
      _toast(
        'Wallet funded',
        '${formatNaira(funded)} was added to your wallet.',
      );
    }
  }
  Future<void> _pay(Shipment shipment) async {
    final confirmed = await showPayConfirmDialog(context, shipment);
    if (confirmed != true) return;
    final error = await _dashboard.payShipment(shipment);
    if (error == null) {
      _toast(
        'Payment successful',
        '${shipment.trackingId} is paid. ${formatNaira(shipment.amount, trimWholeKobo: true)} was deducted from your wallet.',
      );
    } else {
      _toast('Payment failed', error, error: true);
    }
  }
  void _viewMore(Shipment shipment) => showShipmentDetailsDialog(
    context,
    shipment: shipment,
    load: () => _dashboard.shipmentDetails(shipment.id),
  );
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
            onSelected: (d) {
              setState(() => _destination = d);
              if (d == NavDestination.dashboard) _dashboard.loadOverview();
              if (!wide) Navigator.of(context).pop();
            },
            onLogout: _logout,
          ),
        );
        final (title, subtitle) = _destinationHeader(_destination);
        final page = Column(
          children: [
            PageHeader(
              title: title,
              subtitle: subtitle,
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
      case NavDestination.dashboard:
        return _dashboardContent(width);
      default:
        return _PlaceholderDestination(destination: _destination);
    }
  }
  Widget _dashboardContent(double width) {
    final gutter = width < 600 ? 16.0 : 28.0;
    return RefreshIndicator(
      onRefresh: _dashboard.refreshAll,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(gutter, 19, gutter, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PromoCarousel(
              initialPage: 1,
              slides: [
                PromoSlide(headline: 'KEEP UP WITH YOUR\nBUSINESS NEEDS'),
                PromoSlide(headline: 'KEEP UP WITH YOUR\nBUSINESS NEEDS'),
                PromoSlide(headline: 'KEEP UP WITH YOUR\nBUSINESS NEEDS'),
              ],
            ),
            const SizedBox(height: 31),
            _SectionHeader(title: 'Overview', action: _periodPicker()),
            const SizedBox(height: 23),
            Obx(() => _overview(width)),
            const SizedBox(height: 40),
            _SectionHeader(
              title: 'Recent shipment',
              action: Obx(() {
                final total = _dashboard.shipments.value.data?.total ?? 0;
                final expanded = _dashboard.showAllShipments.value;
                if (!expanded && total <= DashboardController.recentLimit) {
                  return const SizedBox.shrink();
                }
                return OutlinedPill(
                  label: expanded ? 'Show Less' : 'See All',
                  onTap: _dashboard.toggleShowAll,
                );
              }),
            ),
            const SizedBox(height: 24),
            Obx(_growthChart),
            ..._shipmentList(),
          ],
        ),
      ),
    );
  }
  Widget _periodPicker() {
    return Obx(
      () => PopupMenuButton<Period>(
        tooltip: 'Select period',
        initialValue: _dashboard.period.value,
        onSelected: _dashboard.setPeriod,
        position: PopupMenuPosition.under,
        color: AppColors.surface,
        itemBuilder: (_) => [
          for (final p in Period.values)
            PopupMenuItem(
              value: p,
              child: Text(
                p.label,
                style: AppText.style(14, color: AppColors.textPrimary),
              ),
            ),
        ],
        child: IgnorePointer(
          child: OutlinedPill(
            label: _dashboard.period.value.label,
            onTap: () {},
            trailing: const AppIcon(
              AppIcons.chevronDown,
              size: 16,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
  Widget _overview(double width) {
    final section = _dashboard.overview.value;
    final data = section.data;
    if (data == null) {
      return section.isLoading
          ? SectionLoading(height: width < 1000 ? 343 : 164)
          : SectionError(
              message: section.error ?? 'Could not load your overview.',
              onRetry: _dashboard.loadOverview,
              height: 164,
            );
    }
    final noun = _dashboard.period.value.noun;
    final balance = BalanceCard(
      balance: formatNaira(data.balance),
      onFundWallet: _fundWallet,
    );
    final stats = [
      StatCard(
        tone: StatTone.shipment,
        label: 'Total Shipment',
        stat: data.shipments,
        periodNoun: noun,
      ),
      StatCard(
        tone: StatTone.exports,
        label: 'Total Exports',
        stat: data.exports,
        periodNoun: noun,
      ),
      StatCard(
        tone: StatTone.imports,
        label: 'Total Import',
        stat: data.imports,
        periodNoun: noun,
      ),
    ];
    final Widget cards;
    if (width < 600) {
      cards = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          balance,
          for (final stat in stats) ...[const SizedBox(height: 15), stat],
        ],
      );
    } else if (width < 1000) {
      cards = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          balance,
          const SizedBox(height: 15),
          Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 15),
                Expanded(child: stats[i]),
              ],
            ],
          ),
        ],
      );
    } else {
      cards = Row(
        children: [
          Expanded(flex: 449, child: balance),
          const SizedBox(width: 24.5),
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(width: 15),
            Expanded(flex: 213, child: stats[i]),
          ],
        ],
      );
    }
    return ReloadingOverlay(
      isLoading: section.isLoading,
      error: section.error,
      onRetry: _dashboard.loadOverview,
      child: cards,
    );
  }
  Widget _growthChart() {
    final section = _dashboard.growth.value;
    final data = section.data;
    return GrowthChartCard(
      values: data?.values ?? const [],
      labels: data?.labels ?? const [],
      range: _dashboard.range.value,
      onRangeChanged: _dashboard.setRange,
      isLoading: section.isLoading,
      error: section.error,
      onRetry: _dashboard.loadGrowth,
    );
  }
  List<Widget> _shipmentList() {
    return [
      Obx(() {
        final section = _dashboard.shipments.value;
        final page = section.data;
        if (page == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: section.isLoading
                ? const SectionLoading(height: 293)
                : SectionError(
                    message: section.error ?? 'Could not load shipments.',
                    onRetry: _dashboard.loadShipments,
                    height: 160,
                  ),
          );
        }
        if (page.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SectionEmpty(
              title: 'No shipments yet',
              message: 'Shipments you send or receive will appear here.',
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final shipment in page.items) ...[
              const SizedBox(height: 10),
              ShipmentCard(
                key: ValueKey(shipment.id),
                shipment: shipment,
                isPaying: _dashboard.paying.contains(shipment.id),
                onViewMore: () => _viewMore(shipment),
                onPayNow: () => _pay(shipment),
              ),
            ],
            if (section.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SectionError(
                  message: section.error!,
                  onRetry: _dashboard.loadShipments,
                  height: 80,
                ),
              ),
          ],
        );
      }),
    ];
  }
  (String, String) _destinationHeader(NavDestination destination) =>
      switch (destination) {
        NavDestination.dashboard => (
            'Invite & Earn',
            'Keep track of your addresses,  location updates. '
                'Edit, Delete, Update and see all your saved addresses',
          ),
        NavDestination.wallet => (
            'Wallet',
            'View your balance, account number and recent transactions.',
          ),
        NavDestination.notifications => (
            'Notifications',
            'Stay updated on your wallet and shipments.',
          ),
        NavDestination.shipments => (
            'Shipments',
            'Create and track your shipments in one place.',
          ),
        NavDestination.services => (
            'Our Services',
            'Everything SecurePay offers, in one place.',
          ),
        NavDestination.addresses => (
            'My Addresses',
            'Save and manage the addresses you ship to.',
          ),
        NavDestination.invite => (
            'Invite & Earn',
            'Refer friends and earn rewards on their shipments.',
          ),
        NavDestination.help => (
            'Help Center',
            'Answers to common questions about SecurePay.',
          ),
      };
}
class _PlaceholderDestination extends StatelessWidget {
  const _PlaceholderDestination({required this.destination});
  final NavDestination destination;
  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(gutter, 19, gutter, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEFFB),
                shape: BoxShape.circle,
              ),
              child: AppIcon(destination.icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              destination.label,
              style: AppText.style(
                16,
                weight: 500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This section is on its way.',
              textAlign: TextAlign.center,
              style: AppText.style(14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final Widget action;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: AppText.style(
                  24,
                  weight: 500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          action,
        ],
      ),
    );
  }
}
