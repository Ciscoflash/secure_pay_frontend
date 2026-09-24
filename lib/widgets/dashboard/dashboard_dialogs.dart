import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shipment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
const _maxFundNaira = 10000000;
Widget _dialogTitle(String text) => Text(
  text,
  style: AppText.style(20, weight: 600, color: AppColors.textPrimary),
);
ButtonStyle _primaryButtonStyle() => FilledButton.styleFrom(
  backgroundColor: AppColors.navyButton,
  foregroundColor: Colors.white,
  minimumSize: const Size(110, 44),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
);
ButtonStyle _secondaryButtonStyle() => TextButton.styleFrom(
  foregroundColor: AppColors.textSecondary,
  minimumSize: const Size(90, 44),
);
Future<int?> showFundWalletDialog(
  BuildContext context, {
  required Future<String?> Function(double amountNaira) onSubmit,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _FundWalletDialog(onSubmit: onSubmit),
  );
}
class _FundWalletDialog extends StatefulWidget {
  const _FundWalletDialog({required this.onSubmit});
  final Future<String?> Function(double amountNaira) onSubmit;
  @override
  State<_FundWalletDialog> createState() => _FundWalletDialogState();
}
class _FundWalletDialogState extends State<_FundWalletDialog> {
  final _amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _serverError;
  bool _submitting = false;
  static const _quickAmounts = [5000, 10000, 50000, 100000];
  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }
  String? _validate(String? value) {
    final amount = double.tryParse((value ?? '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return 'Enter an amount greater than zero';
    }
    if (amount > _maxFundNaira) {
      return 'You can add at most ${formatNaira(_maxFundNaira * 100, trimWholeKobo: true)} at a time';
    }
    return null;
  }
  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amount.text.replaceAll(',', ''));
    setState(() => _submitting = true);
    final error = await widget.onSubmit(amount);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _serverError = error;
      });
      return;
    }
    Navigator.of(context).pop((amount * 100).round());
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: _dialogTitle('Fund wallet'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount (NGN)',
                style: AppText.style(14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amount,
                autofocus: true,
                enabled: !_submitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: _validate,
                onFieldSubmitted: (_) => _submit(),
                style: AppText.style(16, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  prefixText: 'N ',
                  hintText: '0.00',
                  errorText: _serverError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final quick in _quickAmounts)
                    ActionChip(
                      label: Text(
                        formatNaira(quick * 100, trimWholeKobo: true),
                        style: AppText.style(13, color: AppColors.primary),
                      ),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.outline),
                      onPressed: _submitting
                          ? null
                          : () => setState(() => _amount.text = '$quick'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: _secondaryButtonStyle(),
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: _primaryButtonStyle(),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Add funds'),
        ),
      ],
    );
  }
}
Future<bool?> showPayConfirmDialog(BuildContext context, Shipment shipment) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: _dialogTitle('Pay for shipment?'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Text(
          '${formatNaira(shipment.amount, trimWholeKobo: true)} will be '
          'deducted from your wallet to pay for ${shipment.trackingId}.',
          style: AppText.style(14, color: AppColors.textSecondary, height: 1.5),
        ),
      ),
      actions: [
        TextButton(
          style: _secondaryButtonStyle(),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: _primaryButtonStyle(),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Pay now'),
        ),
      ],
    ),
  );
}
Future<void> showShipmentDetailsDialog(
  BuildContext context, {
  required Shipment shipment,
  required Future<Shipment> Function() load,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: _dialogTitle('Shipment details'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 440),
        child: FutureBuilder<Shipment>(
          future: load(),
          initialData: shipment,
          builder: (context, snapshot) {
            final s = snapshot.data ?? shipment;
            final rows = <(String, String)>[
              ('Tracking ID', s.trackingId),
              ('Status', s.status.label),
              ('Payment', s.isPaid ? 'Paid' : 'Not paid'),
              ('Amount', formatNaira(s.amount, trimWholeKobo: true)),
              ('Sender', s.sender),
              ('Receiver', s.receiver),
              ('Pick up from', s.pickUp.name),
              ('Delivery to', s.deliveryTo.name),
              (
                'Type',
                switch (s.direction) {
                  ShipmentDirection.export => 'Export',
                  ShipmentDirection.import => 'Import',
                  ShipmentDirection.local => 'Local',
                },
              ),
              ('Processing time', formatDuration(s.processingHours)),
              if (s.createdAt != null)
                (
                  'Created',
                  MaterialLocalizations.of(context)
                      .formatMediumDate(s.createdAt!),
                ),
            ];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  ),
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Showing saved details — could not refresh: ${snapshot.error}',
                      style: AppText.style(12, color: AppColors.error),
                    ),
                  ),
                for (final (label, value) in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            label,
                            style: AppText.style(
                              13,
                              color: AppColors.textLabel,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value,
                            style: AppText.style(
                              14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          style: _secondaryButtonStyle(),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
