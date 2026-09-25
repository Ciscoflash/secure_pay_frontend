import 'package:flutter/material.dart';
import '../../models/shipment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
class ShipmentCard extends StatefulWidget {
  const ShipmentCard({
    super.key,
    required this.shipment,
    required this.onViewMore,
    required this.onPayNow,
    this.isPaying = false,
    this.initiallyExpanded = true,
  });
  final Shipment shipment;
  final VoidCallback onViewMore;
  final VoidCallback onPayNow;
  final bool isPaying;
  final bool initiallyExpanded;
  @override
  State<ShipmentCard> createState() => _ShipmentCardState();
}
class _ShipmentCardState extends State<ShipmentCard> {
  late bool _expanded = widget.initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _Cells(
                        compact: compact,
                        cells: [
                          (
                            272,
                            _Field(
                              label: 'Tracking ID',
                              child: _Value(
                                s.trackingId,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          (
                            206,
                            _Field(label: 'Sender', child: _Value(s.sender)),
                          ),
                          (
                            578,
                            _Field(
                              label: 'Receiver',
                              child: _Value(s.receiver),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _expanded ? 'Collapse' : 'Expand',
                      onPressed: () => setState(() => _expanded = !_expanded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      icon: AnimatedRotation(
                        turns: _expanded ? 0 : 0.5,
                        duration: const Duration(milliseconds: 200),
                        child: const AppIcon(
                          AppIcons.chevronUp,
                          color: Color(0xFF14360A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? _details(s, compact)
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _details(Shipment s, bool compact) {
    final processing = _Field(
      label: 'Processing time',
      gap: 3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(AppIcons.stopwatch, color: Color(0xFF3A3A3A)),
          const SizedBox(width: 7),
          _Value(formatDuration(s.processingHours)),
        ],
      ),
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CardButton.outlined('View More', onTap: widget.onViewMore),
        const SizedBox(width: 6),
        if (s.isPaid)
          const _CardButton.disabled('Paid')
        else
          _CardButton.filled(
            'Pay Now',
            onTap: widget.isPaying ? null : widget.onPayNow,
            isLoading: widget.isPaying,
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: AppColors.rowDivider),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: _Cells(
            compact: compact,
            crossAxisAlignment: CrossAxisAlignment.end,
            cells: [
              (366, _Field(label: 'Pick Up From', child: _Place(s.pickUp))),
              (361, _Field(label: 'Delivery To', child: _Place(s.deliveryTo))),
              (
                296,
                _Field(
                  label: 'Amount',
                  child: _Value(formatNaira(s.amount, trimWholeKobo: true)),
                ),
              ),
              (
                null,
                _Field(label: 'Status', gap: 6.5, child: StatusPill(s.status)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.rowDivider),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 27, 0, 29.5),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [processing, const SizedBox(height: 16), actions],
                )
              : Row(
                  children: [
                    Expanded(child: processing),
                    actions,
                  ],
                ),
        ),
      ],
    );
  }
}
class _Cells extends StatelessWidget {
  const _Cells({
    required this.compact,
    required this.cells,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });
  final bool compact;
  final List<(int?, Widget)> cells;
  final CrossAxisAlignment crossAxisAlignment;
  @override
  Widget build(BuildContext context) {
    if (compact) {
      return LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            for (final (_, child) in cells)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: child,
              ),
          ],
        ),
      );
    }
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (final (flex, child) in cells)
          flex == null ? child : Expanded(flex: flex, child: child),
      ],
    );
  }
}
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.gap = 5});
  final String label;
  final Widget child;
  final double gap;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
        SizedBox(height: gap),
        child,
      ],
    );
  }
}
class _Value extends StatelessWidget {
  const _Value(this.text, {this.color = AppColors.textPrimary});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: AppText.style(16, color: color, height: 1.5),
    );
  }
}
class _Place extends StatelessWidget {
  const _Place(this.place);
  final Place place;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (place.countryCode == 'NG')
          const NigeriaFlag()
        else
          CountryBadge(place.countryCode),
        const SizedBox(width: 8),
        Flexible(child: _Value(place.name)),
      ],
    );
  }
}
class NigeriaFlag extends StatelessWidget {
  const NigeriaFlag({super.key});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF449852);
    return Semantics(
      label: 'Nigeria',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: const SizedBox(
          width: 19,
          height: 13,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ColoredBox(color: green)),
              Expanded(child: ColoredBox(color: Color(0xFFEEEEEE))),
              Expanded(child: ColoredBox(color: green)),
            ],
          ),
        ),
      ),
    );
  }
}
class CountryBadge extends StatelessWidget {
  const CountryBadge(this.code, {super.key});
  final String code;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 13,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        code,
        style: AppText.style(7, weight: 700, color: AppColors.primary),
      ),
    );
  }
}
class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});
  final ShipmentStatus status;
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      ShipmentStatus.pending => (
        const Color(0xFFF1F1F1),
        const Color(0xFF525252),
      ),
      ShipmentStatus.inTransit => (
        const Color(0xFFFBEBDB),
        const Color(0xFFC18855),
      ),
      ShipmentStatus.delayed => (
        const Color(0xFFCCF9FE),
        const Color(0xFF123236),
      ),
      ShipmentStatus.delivered => (
        const Color(0xFFE0FEDA),
        const Color(0xFF2F6B1F),
      ),
    };
    return Container(
      width: 74,
      height: 33,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status.label, style: AppText.style(12, color: fg)),
    );
  }
}
class _CardButton extends StatelessWidget {
  const _CardButton.outlined(this.label, {required this.onTap})
    : _style = _ButtonStyle.outlined,
      isLoading = false;
  const _CardButton.filled(
    this.label, {
    required this.onTap,
    this.isLoading = false,
  }) : _style = _ButtonStyle.filled;
  const _CardButton.disabled(this.label)
    : onTap = null,
      isLoading = false,
      _style = _ButtonStyle.disabled;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final _ButtonStyle _style;
  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, height) = switch (_style) {
      _ButtonStyle.outlined => (
        AppColors.surface,
        const Color(0xFF21243B),
        const Color(0xFF21243B),
        35.0,
      ),
      _ButtonStyle.filled => (
        AppColors.navyButton,
        Colors.white,
        AppColors.navyButton,
        32.0,
      ),
      _ButtonStyle.disabled => (
        AppColors.cardBorder,
        const Color(0xFF808080),
        AppColors.cardBorder,
        33.0,
      ),
    };
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: _style == _ButtonStyle.outlined
            ? const [
                BoxShadow(
                  color: Color(0x2E21243B),
                  offset: Offset(0, 2),
                  blurRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          mouseCursor: isLoading
              ? SystemMouseCursors.progress
              : onTap == null
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: Container(
            width: _style == _ButtonStyle.outlined ? 94 : 90,
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                      semanticsLabel: 'Paying',
                    ),
                  )
                : Text(label, style: AppText.style(12, weight: 600, color: fg)),
          ),
        ),
      ),
    );
  }
}
enum _ButtonStyle { outlined, filled, disabled }
