import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/dashboard.dart';
import '../../models/shipment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
import 'dashboard_dialogs.dart';
import 'growth_chart.dart';
import 'overview_cards.dart';
import 'promo_banner.dart';
import 'section_header.dart';
import 'section_states.dart';
import 'shipment_card.dart';
import 'shipment_detail_page.dart';
class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key, required this.width});
  final double width;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final gutter = width < 600 ? 16.0 : 28.0;
    return RefreshIndicator(
      onRefresh: controller.refreshAll,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(gutter, 19, gutter, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PromoCarousel(
              slides: [
                PromoSlide(headline: 'KEEP UP WITH YOUR\nBUSINESS NEEDS'),
                PromoSlide(headline: 'TRACK EVERY PACKAGE\nIN REAL TIME'),
                PromoSlide(headline: 'SHIP TO 300+ COUNTRIES\nFROM NIGERIA'),
              ],
            ),
            const SizedBox(height: 31),
            SectionHeader(title: 'Overview', action: _periodPicker(controller)),
            const SizedBox(height: 23),
            Obx(() => _overview(context, controller)),
            const SizedBox(height: 40),
            SectionHeader(
              title: 'Recent shipment',
              action: Obx(() {
                final total = controller.shipments.value.data?.total ?? 0;
                final expanded = controller.showAllShipments.value;
                if (!expanded && total <= DashboardController.recentLimit) {
                  return const SizedBox.shrink();
                }
                return OutlinedPill(
                  label: expanded ? 'Show Less' : 'See All',
                  onTap: controller.toggleShowAll,
                );
              }),
            ),
            const SizedBox(height: 24),
            Obx(() => _growthChart(context, controller)),
            ..._shipmentList(context, controller),
          ],
        ),
      ),
    );
  }
  Widget _periodPicker(DashboardController controller) {
    return Obx(
      () => PopupMenuButton<Period>(
        tooltip: 'Select period',
        initialValue: controller.period.value,
        onSelected: controller.setPeriod,
        position: PopupMenuPosition.under,
        color: AppColors.surface,
        itemBuilder: (_) => [
          for (final period in Period.values)
            PopupMenuItem(
              value: period,
              child: Text(
                period.label,
                style: AppText.style(14, color: AppColors.textPrimary),
              ),
            ),
        ],
        child: IgnorePointer(
          child: OutlinedPill(
            label: controller.period.value.label,
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
  Widget _overview(BuildContext context, DashboardController controller) {
    final section = controller.overview.value;
    final data = section.data;
    if (data == null) {
      return section.isLoading
          ? SectionLoading(height: width < 1000 ? 343 : 164)
          : SectionError(
              message: section.error ?? 'Could not load your overview.',
              onRetry: controller.loadOverview,
              height: 164,
            );
    }
    final noun = controller.period.value.noun;
    final balance = BalanceCard(
      balance: formatNaira(data.balance),
      onFundWallet: () => _fundWallet(context),
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
      onRetry: controller.loadOverview,
      child: cards,
    );
  }
  Widget _growthChart(BuildContext context, DashboardController controller) {
    final section = controller.growth.value;
    final data = section.data;
    return GrowthChartCard(
      values: data?.values ?? const [],
      labels: data?.labels ?? const [],
      range: controller.range.value,
      onRangeChanged: controller.setRange,
      isLoading: section.isLoading,
      error: section.error,
      onRetry: controller.loadGrowth,
    );
  }
  List<Widget> _shipmentList(BuildContext context, DashboardController controller) {
    return [
      Obx(() {
        final section = controller.shipments.value;
        final page = section.data;
        if (page == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: section.isLoading
                ? const SectionLoading(height: 293)
                : SectionError(
                    message: section.error ?? 'Could not load shipments.',
                    onRetry: controller.loadShipments,
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
                isPaying: controller.paying.contains(shipment.id),
                onViewMore: () => _viewMore(context, shipment),
                onPayNow: () => _pay(context, shipment),
              ),
            ],
            if (section.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SectionError(
                  message: section.error!,
                  onRetry: controller.loadShipments,
                  height: 80,
                ),
              ),
          ],
        );
      }),
    ];
  }
  Future<void> _fundWallet(BuildContext context) async {
    final funded = await showFundWalletDialog(
      context,
      onSubmit: Get.find<DashboardController>().fundWallet,
    );
    if (funded != null) {
      showAppSnackbar(
        'Wallet funded',
        '${formatNaira(funded)} was added to your wallet.',
      );
    }
  }
  Future<void> _pay(BuildContext context, Shipment shipment) async {
    final confirmed = await showPayConfirmDialog(context, shipment);
    if (confirmed != true) return;
    final error = await Get.find<DashboardController>().payShipment(shipment);
    if (error == null) {
      showAppSnackbar(
        'Payment successful',
        '${shipment.trackingId} is paid. ${formatNaira(shipment.amount, trimWholeKobo: true)} was deducted from your wallet.',
      );
    } else {
      showAppSnackbar('Payment failed', error, error: true);
    }
  }
  void _viewMore(BuildContext context, Shipment shipment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShipmentDetailPage(shipment: shipment),
      ),
    );
  }
}