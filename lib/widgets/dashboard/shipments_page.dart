import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/shipments_controller.dart';
import '../../models/shipment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
import 'dashboard_dialogs.dart';
import 'section_states.dart';
import 'shipment_card.dart';
import 'shipment_detail_page.dart';
class ShipmentsPage extends StatefulWidget {
  const ShipmentsPage({super.key});
  @override
  State<ShipmentsPage> createState() => _ShipmentsPageState();
}
class _ShipmentsPageState extends State<ShipmentsPage> {
  ShipmentsController get _ctrl => Get.find<ShipmentsController>();
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
  int? _walletBalance() =>
      Get.find<DashboardController>().overview.value.data?.balance;
  Future<void> _newShipment() async {
    final result = await showCreateShipmentDialog(
      context,
      estimate: _ctrl.estimate,
      submit: _ctrl.create,
      walletBalance: _walletBalance(),
    );
    if (result != null && mounted) {
      showAppSnackbar(
        'Shipment created',
        '${result.shipment.trackingId} '
        '${result.shipment.isPaid ? 'is paid' : 'is awaiting payment'}.',
      );
    }
  }
  Future<void> _pay(Shipment shipment) async {
    final confirmed = await showPayConfirmDialog(context, shipment);
    if (confirmed != true) return;
    final error = await _ctrl.payShipment(shipment);
    if (!mounted) return;
    if (error != null) {
      showAppSnackbar('Payment failed', error, error: true);
      return;
    }
    showAppSnackbar(
      'Payment successful',
      '${shipment.trackingId} is paid. '
      '${formatNaira(shipment.amount, trimWholeKobo: true)} was deducted '
      'from your wallet.',
    );
  }
  void _openDetails(Shipment shipment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShipmentDetailPage(shipment: shipment),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = width < 600 ? 16.0 : 28.0;
    return RefreshIndicator(
      onRefresh: _ctrl.load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(gutter, 19, gutter, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _toolbar(width < 800),
            const SizedBox(height: 16),
            Obx(() => _filters()),
            const SizedBox(height: 20),
            Obx(() => _list()),
            Obx(() {
              final page = _ctrl.page.value.data;
              if (page == null || page.totalPages <= 1) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 18),
                child: _pagination(page),
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _toolbar(bool compact) {
    final button = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navyButton,
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: _newShipment,
      icon: const AppIcon(AppIcons.truck, size: 16, color: Colors.white),
      label: const Text('New shipment'),
    );
    final field = SizedBox(
      width: compact ? double.infinity : 300,
      child: TextField(
        controller: _search,
        onChanged: _ctrl.setSearch,
        style: AppText.style(15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by tracking ID, sender or receiver',
          hintStyle: AppText.style(14, color: AppColors.textMuted),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textMuted,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          field,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: button),
        ],
      );
    }
    return Row(
      children: [
        field,
        const Spacer(),
        button,
      ],
    );
  }
  Widget _filters() {
    final status = _ctrl.status.value;
    final direction = _ctrl.direction.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
              label: 'All',
              selected: status == null,
              onTap: () => _ctrl.setStatus(null),
            ),
            for (final s in ShipmentStatus.values)
              _FilterChip(
                label: s.label,
                selected: status == s,
                onTap: () => _ctrl.setStatus(s),
              ),
            const SizedBox(width: 14),
            _FilterChip(
              label: 'All directions',
              selected: direction == null,
              onTap: () => _ctrl.setDirection(null),
            ),
            for (final d in ShipmentDirection.values)
              _FilterChip(
                label: d.label,
                selected: direction == d,
                onTap: () => _ctrl.setDirection(d),
              ),
          ],
        ),
      ],
    );
  }
  Widget _list() {
    final section = _ctrl.page.value;
    final page = section.data;
    if (page == null) {
      return section.isLoading
          ? const SectionLoading(height: 300)
          : SectionError(
              message: section.error ?? 'Could not load shipments.',
              onRetry: _ctrl.load,
              height: 220,
            );
    }
    if (page.items.isEmpty) {
      final filtered =
          _ctrl.search.value.isNotEmpty ||
          _ctrl.status.value != null ||
          _ctrl.direction.value != null;
      return SectionEmpty(
        title: filtered ? 'No matching shipments' : 'No shipments yet',
        message: filtered
            ? 'Try changing your filters or search terms.'
            : 'Create your first shipment to get started.',
      );
    }
    final loading = section.isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: loading ? 0.55 : 1,
          child: Column(
            children: [
              for (final shipment in page.items) ...[
                const SizedBox(height: 10),
                ShipmentCard(
                  key: ValueKey(shipment.id),
                  shipment: shipment,
                  isPaying: _ctrl.paying.contains(shipment.id),
                  onViewMore: () => _openDetails(shipment),
                  onPayNow: () => _pay(shipment),
                ),
              ],
            ],
          ),
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        if (section.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SectionError(
              message: section.error!,
              onRetry: _ctrl.load,
              height: 80,
            ),
          ),
      ],
    );
  }
  Widget _pagination(ShipmentPage page) {
    final canPrev = page.page > 1;
    final canNext = page.page < page.totalPages;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing ${page.items.length} of ${page.total} shipments',
            overflow: TextOverflow.ellipsis,
            style: AppText.style(13, color: AppColors.textMuted),
          ),
        ),
        _PageButton(
          icon: Icons.arrow_back_ios_new,
          tooltip: 'Previous page',
          onTap: canPrev ? () => _ctrl.goToPage(page.page - 1) : null,
        ),
        const SizedBox(width: 12),
        Text(
          'Page ${page.page} of ${page.totalPages}',
          style: AppText.style(14, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 12),
        _PageButton(
          icon: Icons.arrow_forward_ios,
          tooltip: 'Next page',
          onTap: canNext ? () => _ctrl.goToPage(page.page + 1) : null,
        ),
      ],
    );
  }
}
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navyButton : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: selected ? AppColors.navyButton : AppColors.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppText.style(
              13,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: onTap == null ? AppColors.cardBorder : AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              size: 15,
              color: onTap == null ? AppColors.textPlaceholder : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}