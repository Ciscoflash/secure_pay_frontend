import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shipments_controller.dart';
import '../../models/shipment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
import 'dashboard_dialogs.dart';
import 'shipment_card.dart';
class ShipmentDetailPage extends StatefulWidget {
  const ShipmentDetailPage({super.key, required this.shipment});
  final Shipment shipment;
  @override
  State<ShipmentDetailPage> createState() => _ShipmentDetailPageState();
}
class _ShipmentDetailPageState extends State<ShipmentDetailPage> {
  late Shipment _shipment = widget.shipment;
  late final ShipmentsController _controller = Get.find<ShipmentsController>();
  bool _refreshing = false;
  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final fresh = await _controller.shipmentDetails(_shipment.id);
      if (mounted) setState(() => _shipment = fresh);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }
  Future<void> _pay() async {
    final confirmed = await showPayConfirmDialog(context, _shipment);
    if (confirmed != true) return;
    final error = await _controller.payShipment(_shipment);
    if (!mounted) return;
    if (error != null) {
      showAppSnackbar('Payment failed', error, error: true);
      return;
    }
    showAppSnackbar(
      'Payment successful',
      '${_shipment.trackingId} is paid. '
      '${formatNaira(_shipment.amount, trimWholeKobo: true)} was deducted from '
      'your wallet.',
    );
    await _refresh();
  }
  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Shipment details',
          style: AppText.style(20, weight: 600, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summaryCard(),
              const SizedBox(height: 20),
              _journeyCard(),
              const SizedBox(height: 20),
              _trackingCard(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _summaryCard() {
    final s = _shipment;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracking ID',
                      style: AppText.style(
                        12,
                        color: AppColors.textLabel,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.trackingId,
                      style: AppText.style(
                        18,
                        weight: 600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(s.status),
            ],
          ),
          const Divider(
            height: 25,
            thickness: 1,
            color: AppColors.rowDivider,
          ),
          Text(
            '${s.sender}  →  ${s.receiver}',
            style: AppText.style(16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${s.direction.label} • ${formatDuration(s.processingHours)} '
            'processing time',
            style: AppText.style(14, color: AppColors.textMuted),
          ),
          const Divider(
            height: 25,
            thickness: 1,
            color: AppColors.rowDivider,
          ),
          Row(
            children: [
              Expanded(
                child: _amountBlock(s),
              ),
              if (!s.isPaid)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navyButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _refreshing ? null : _pay,
                  icon: const AppIcon(
                    AppIcons.truck,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text('Pay now'),
                ),
            ],
          ),
          if (s.createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Created on ${_formatDate(s.createdAt!)}',
                style: AppText.style(12, color: AppColors.textLabel),
              ),
            ),
        ],
      ),
    );
  }
  Widget _amountBlock(Shipment s) {
    final statusText = s.isPaid
        ? 'Paid on ${s.paidAt != null ? _formatDate(s.paidAt!) : ''}'
        : 'Not paid yet';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery charge',
          style: AppText.style(
            12,
            color: AppColors.textLabel,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              formatNaira(s.amount, trimWholeKobo: true),
              style: AppText.style(18, weight: 600, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 10),
            Text(
              statusText,
              style: AppText.style(
                13,
                color: s.isPaid ? AppColors.success : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _journeyCard() {
    final s = _shipment;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Journey',
            style: AppText.style(14, weight: 600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _JourneyStop(
            icon: const AppIcon(AppIcons.arrowUp, size: 18, color: AppColors.primary),
            label: 'Pick up from',
            place: s.pickUp,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Container(
              width: 2,
              height: 24,
              color: AppColors.rowDivider,
            ),
          ),
          _JourneyStop(
            icon: const AppIcon(AppIcons.arrowDown, size: 18, color: AppColors.primary),
            label: 'Deliver to',
            place: s.deliveryTo,
          ),
        ],
      ),
    );
  }
  Widget _trackingCard() {
    final s = _shipment;
    final events = s.events.isNotEmpty ? s.events : _synthesizedEvents(s);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tracking history',
            style: AppText.style(14, weight: 600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < events.length; i++)
            _TimelineEntry(
              event: events[events.length - 1 - i],
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
  List<TrackingEvent> _synthesizedEvents(Shipment s) {
    final result = <TrackingEvent>[];
    if (s.createdAt != null) {
      result.add(
        TrackingEvent(
          status: ShipmentStatus.pending,
          note: 'Shipment created',
          at: s.createdAt!,
        ),
      );
    }
    if (s.isPaid && s.paidAt != null) {
      result.add(
        TrackingEvent(
          status: ShipmentStatus.pending,
          note: 'Payment received',
          at: s.paidAt!,
        ),
      );
    }
    if (s.createdAt != null) {
      result.add(
        TrackingEvent(
          status: s.status,
          note: switch (s.status) {
            ShipmentStatus.pending => 'Awaiting pickup',
            ShipmentStatus.inTransit => 'Package in transit',
            ShipmentStatus.delayed => 'Delivery delayed',
            ShipmentStatus.delivered => 'Delivered to destination',
          },
          at: s.createdAt!,
        ),
      );
    }
    return result;
  }
  String _formatDate(DateTime time) =>
      MaterialLocalizations.of(context).formatMediumDate(time);
}
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }
}
class _JourneyStop extends StatelessWidget {
  const _JourneyStop({
    required this.icon,
    required this.label,
    required this.place,
  });
  final Widget icon;
  final String label;
  final Place place;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppText.style(
                  12,
                  color: AppColors.textLabel,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (place.countryCode == 'NG')
                    const NigeriaFlag()
                  else
                    CountryBadge(place.countryCode),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place.name,
                      style: AppText.style(15, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.event, required this.isLast});
  final TrackingEvent event;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    final (dot, labelColor) = switch (event.status) {
      ShipmentStatus.pending => (AppColors.dotInactive, AppColors.textSecondary),
      ShipmentStatus.inTransit => (const Color(0xFFC18855), AppColors.textPrimary),
      ShipmentStatus.delayed => (const Color(0xFF123236), AppColors.textPrimary),
      ShipmentStatus.delivered => (AppColors.success, AppColors.textPrimary),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.rowDivider),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.note,
                    style: AppText.style(15, weight: 500, color: labelColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.status.label} • ${formatRelativeTime(event.at)}',
                    style: AppText.style(13, color: AppColors.textLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}