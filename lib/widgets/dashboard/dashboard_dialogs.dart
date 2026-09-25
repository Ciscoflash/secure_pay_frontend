import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shipment.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
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
Future<CreateShipmentResult?> showCreateShipmentDialog(
  BuildContext context, {
  required Future<EstimateResult> Function({
    required Place pickUp,
    required Place deliveryTo,
  })
  estimate,
  required Future<CreateShipmentResult> Function({
    required String sender,
    required String receiver,
    required Place pickUp,
    required Place deliveryTo,
  })
  submit,
  int? walletBalance,
}) {
  return showDialog<CreateShipmentResult>(
    context: context,
    builder: (_) => _CreateShipmentDialog(
      estimate: estimate,
      submit: submit,
      walletBalance: walletBalance,
    ),
  );
}
const _shipmentCountries = [
  (code: 'NG', name: 'Nigeria'),
  (code: 'GH', name: 'Ghana'),
  (code: 'GB', name: 'United Kingdom'),
  (code: 'US', name: 'United States'),
  (code: 'CA', name: 'Canada'),
  (code: 'AE', name: 'United Arab Emirates'),
];
class _CreateShipmentDialog extends StatefulWidget {
  const _CreateShipmentDialog({
    required this.estimate,
    required this.submit,
    this.walletBalance,
  });
  final Future<EstimateResult> Function({
    required Place pickUp,
    required Place deliveryTo,
  })
  estimate;
  final Future<CreateShipmentResult> Function({
    required String sender,
    required String receiver,
    required Place pickUp,
    required Place deliveryTo,
  })
  submit;
  final int? walletBalance;
  @override
  State<_CreateShipmentDialog> createState() => _CreateShipmentDialogState();
}
class _CreateShipmentDialogState extends State<_CreateShipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sender = TextEditingController();
  final _receiver = TextEditingController();
  final _pickUpPlace = TextEditingController();
  final _deliveryPlace = TextEditingController();
  var _pickUpCountry = 'NG';
  var _deliveryCountry = 'NG';
  Timer? _debounce;
  EstimateResult? _quote;
  bool _quoting = false;
  String? _serverError;
  bool _submitting = false;
  @override
  void initState() {
    super.initState();
    _scheduleQuote();
  }
  @override
  void dispose() {
    _debounce?.cancel();
    _sender.dispose();
    _receiver.dispose();
    _pickUpPlace.dispose();
    _deliveryPlace.dispose();
    super.dispose();
  }
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
  void _onChanged(String _) => _scheduleQuote();
  void _scheduleQuote() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetchQuote);
  }
  Future<void> _fetchQuote() async {
    final pickUp = Place(
      _pickUpPlace.text.trim().isEmpty ? 'Lagos, Nigeria' : _pickUpPlace.text.trim(),
      countryCode: _pickUpCountry,
    );
    final deliveryTo = Place(
      _deliveryPlace.text.trim().isEmpty
          ? 'Lagos, Nigeria'
          : _deliveryPlace.text.trim(),
      countryCode: _deliveryCountry,
    );
    setState(() => _quoting = true);
    try {
      final quote = await widget.estimate(
        pickUp: pickUp,
        deliveryTo: deliveryTo,
      );
      if (!mounted) return;
      setState(() => _quote = quote);
    } on ApiException {
      if (mounted) setState(() => _quote = null);
    } finally {
      if (mounted) setState(() => _quoting = false);
    }
  }
  Future<void> _submit() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final result = await widget.submit(
        sender: _sender.text.trim(),
        receiver: _receiver.text.trim(),
        pickUp: Place(_pickUpPlace.text.trim(), countryCode: _pickUpCountry),
        deliveryTo: Place(
          _deliveryPlace.text.trim(),
          countryCode: _deliveryCountry,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _serverError = error.message;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final quote = _quote;
    final balance = widget.walletBalance;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: _dialogTitle('Create a shipment'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 460, maxWidth: 560),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sender',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sender,
                validator: _required,
                style: AppText.style(16, color: AppColors.textPrimary),
                decoration: _fieldDecoration('Who is sending the package?'),
              ),
              const SizedBox(height: 14),
              const Text(
                'Receiver',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _receiver,
                validator: _required,
                style: AppText.style(16, color: AppColors.textPrimary),
                decoration: _fieldDecoration('Who is receiving the package?'),
              ),
              const SizedBox(height: 18),
              _placeRow(
                label: 'Pick up from',
                country: _pickUpCountry,
                controller: _pickUpPlace,
                onCountry: (code) {
                  setState(() => _pickUpCountry = code);
                  _scheduleQuote();
                },
              ),
              const SizedBox(height: 18),
              _placeRow(
                label: 'Deliver to',
                country: _deliveryCountry,
                controller: _deliveryPlace,
                onCountry: (code) {
                  setState(() => _deliveryCountry = code);
                  _scheduleQuote();
                },
              ),
              const SizedBox(height: 18),
              _quotePanel(context, quote),
              if (_serverError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _serverError!,
                  style: AppText.style(13, color: AppColors.error),
                ),
              ],
              if (quote != null &&
                  balance != null &&
                  quote.amount > balance) ...[
                const SizedBox(height: 10),
                Text(
                  'Your wallet balance is below this amount, so the shipment '
                  'will be created unpaid. Pay from your shipment list when '
                  'ready.',
                  style: AppText.style(12, color: AppColors.textMuted),
                ),
              ],
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
              : const Text('Create shipment'),
        ),
      ],
    );
  }
  Widget _placeRow({
    required String label,
    required String country,
    required TextEditingController controller,
    required ValueChanged<String> onCountry,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.style(14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 175,
              child: DropdownButtonFormField<String>(
                initialValue: country,
                isExpanded: true,
                decoration: _fieldDecoration(null),
                style: AppText.style(16, color: AppColors.textPrimary),
                icon: const AppIcon(
                  AppIcons.chevronDown,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                items: [
                  for (final (:code, :name) in _shipmentCountries)
                    DropdownMenuItem(
                      value: code,
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.style(14, color: AppColors.textPrimary),
                      ),
                    ),
                ],
                onChanged: (code) => onCountry(code ?? 'NG'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: !_submitting,
                validator: _required,
                onChanged: _onChanged,
                style: AppText.style(16, color: AppColors.textPrimary),
                decoration: _fieldDecoration('City or area'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _quotePanel(BuildContext context, EstimateResult? quote) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE4FB)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              'Estimated delivery charge',
              style: AppText.style(14, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),
          if (_quoting)
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else if (quote != null)
            Flexible(
              child: Text(
                '${quote.direction.label} • '
                '${formatNaira(quote.amount, trimWholeKobo: true)}',
                overflow: TextOverflow.ellipsis,
                style: AppText.style(
                  14,
                  weight: 600,
                  color: AppColors.navyButton,
                ),
              ),
            )
          else
            Text(
              'Select destinations',
              style: AppText.style(13, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
  InputDecoration _fieldDecoration(String? hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppText.style(14, color: AppColors.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
  );
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
