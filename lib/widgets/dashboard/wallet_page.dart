import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/section.dart';
import '../../models/wallet.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/feedback.dart';
import '../../utils/formatters.dart';
import 'app_icon.dart';
import 'dashboard_dialogs.dart' show showFundWalletDialog;
import 'overview_cards.dart' show BalanceCard;
import 'section_states.dart';
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});
  @override
  State<WalletPage> createState() => _WalletPageState();
}
class _WalletPageState extends State<WalletPage> {
  WalletController get _ctrl => Get.find<WalletController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.load());
  }
  Future<void> _fund() async {
    final funded = await showFundWalletDialog(context, onSubmit: _ctrl.fundWallet);
    if (funded == null) return;
    showAppSnackbar(
      'Wallet funded',
      '${formatNaira(funded)} was added to your wallet.',
    );
    _ctrl.load();
  }
  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return Obx(() {
      final section = _ctrl.account.value;
      return RefreshIndicator(
        onRefresh: _ctrl.load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(gutter, 19, gutter, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_WalletCards(section: section, onFund: _fund)],
          ),
        ),
      );
    });
  }
}
class _WalletCards extends StatelessWidget {
  const _WalletCards({required this.section, required this.onFund});
  final Section<WalletAccount> section;
  final VoidCallback onFund;
  @override
  Widget build(BuildContext context) {
    final data = section.data;
    if (data == null) {
      return section.isLoading
          ? const SectionLoading(height: 164)
          : SectionError(
              message: section.error ?? 'Could not load your wallet.',
              onRetry: () => Get.find<WalletController>().load(),
              height: 164,
            );
    }
    final balance = BalanceCard(
      balance: formatNaira(data.balance),
      onFundWallet: onFund,
    );
    final account = AccountCard(account: data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 820) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  balance,
                  const SizedBox(height: 15),
                  account,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: balance),
                const SizedBox(width: 15),
                Expanded(child: account),
              ],
            );
          },
        ),
        const SizedBox(height: 34),
        Text(
          'Transactions',
          style: AppText.style(
            24,
            weight: 500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _TransactionList(section: section),
      ],
    );
  }
}
class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.account});
  final WalletAccount account;
  @override
  State<AccountCard> createState() => _AccountCardState();
}
class _AccountCardState extends State<AccountCard> {
  bool _copied = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Account',
            style: AppText.style(12, color: AppColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            widget.account.bankName,
            style: AppText.style(13, weight: 500, color: AppColors.textPrimary),
          ),
          const Spacer(),
          Text(
            _grouped(widget.account.accountNumber),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              height: 1.2,
              fontVariations: const [FontVariation('wght', 700)],
              fontFeatures: const [FontFeature.tabularFigures()],
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Send a transfer to this number to fund your wallet.',
                  style: AppText.style(11, color: AppColors.textMuted, height: 1.4),
                ),
              ),
              const SizedBox(width: 8),
              _CopyNumberButton(
                number: widget.account.accountNumber,
                copied: _copied,
                onPressed: _copy,
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _grouped(String number) {
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(number[i]);
    }
    return buffer.toString();
  }
  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.account.accountNumber));
    if (!mounted) return;
    setState(() => _copied = true);
    showAppSnackbar('Copied', 'Account number copied to your clipboard.');
  }
}
class _CopyNumberButton extends StatelessWidget {
  const _CopyNumberButton({
    required this.number,
    required this.copied,
    required this.onPressed,
  });
  final String number;
  final bool copied;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: copied ? 'Copied' : 'Copy account number',
      button: true,
      child: Material(
        color: copied ? const Color(0xFFE0FEDA) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: copied ? AppColors.success : AppColors.outline,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: copied ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  copied ? Icons.check : Icons.copy,
                  size: 13,
                  color: copied ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  copied ? 'Copied' : 'Copy number',
                  style: AppText.style(
                    12,
                    color: copied ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.section});
  final Section<WalletAccount> section;
  @override
  Widget build(BuildContext context) {
    final data = section.data;
    if (data == null) {
      return const SizedBox.shrink();
    }
    if (data.transactions.isEmpty) {
      return const SectionEmpty(
        title: 'No transactions yet',
        message: 'Your wallet activity will appear here.',
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
          for (var i = 0; i < data.transactions.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.rowDivider),
            _TransactionRow(transaction: data.transactions[i]),
          ],
        ],
      ),
    );
  }
}
class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});
  final WalletTransaction transaction;
  @override
  Widget build(BuildContext context) {
    final credit = transaction.isCredit;
    final toneColor = credit ? AppColors.success : AppColors.error;
    final background = credit
        ? const Color(0xFFE0FEDA)
        : const Color(0xFFFDE9E9);
    final icon = credit ? AppIcons.arrowUp : AppIcons.arrowDown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: AppIcon(icon, size: 18, color: toneColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(14, color: AppColors.textPrimary),
                ),
                if (transaction.createdAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    formatRelativeTime(transaction.createdAt!),
                    style: AppText.style(11, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${credit ? '+' : '-'}${formatNaira(transaction.amount, trimWholeKobo: true)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontVariations: const [FontVariation('wght', 600)],
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: toneColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Balance ${formatNaira(transaction.balanceAfter, trimWholeKobo: true)}',
                style: AppText.style(11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}