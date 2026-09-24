import 'package:flutter/material.dart';

import '../../models/dashboard.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'app_icon.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.onFundWallet,
  });

  final String balance;
  final VoidCallback onFundWallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 25),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Balance',
            style: AppText.style(
              12,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            balance,
            style: AppText.style(
              26,
              weight: 700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const Spacer(),
          _SmallButton(
            label: 'Fund Wallet',
            onPressed: onFundWallet,
            background: Colors.white,
            foreground: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

enum StatTone {
  shipment(Color(0xFFF1E4C7), Color(0xFFBF8B32), AppIcons.truck),
  exports(Color(0xFFE0FEDA), Color(0xFF5AC03A), AppIcons.arrowUp),
  imports(Color(0xFFDEFCFE), Color(0xFF479DA5), AppIcons.arrowDown);

  const StatTone(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  final AppIcons icon;
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.tone,
    required this.label,
    required this.stat,
    required this.periodNoun,
  });

  final StatTone tone;
  final String label;
  final StatValue stat;

  /// "week", "month" or "year" — completes "Vs last …".
  final String periodNoun;

  @override
  Widget build(BuildContext context) {
    final change = stat.changePct;
    final down = change != null && change < 0;
    final changeColor = down ? AppColors.error : AppColors.success;

    return Container(
      height: 164,
      padding: const EdgeInsets.fromLTRB(16, 34, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tone.background,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(tone.icon, color: tone.foreground),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(13, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${stat.current}',
                style: AppText.style(
                  24,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 9),
                AppIcon(
                  down ? AppIcons.arrowDown : AppIcons.arrowUp,
                  size: 13,
                  color: changeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${change.abs()}%',
                  semanticsLabel:
                      '${down ? 'down' : 'up'} ${change.abs()} percent',
                  style: AppText.style(13, weight: 500, color: changeColor),
                ),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Text.rich(
            TextSpan(
              style: AppText.style(8, color: AppColors.textMuted),
              children: [
                TextSpan(text: 'Vs last $periodNoun: '),
                TextSpan(
                  text: '${stat.previous}',
                  style: AppText.style(
                    11,
                    weight: 500,
                    color: AppColors.textPrimary,
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

/// Outlined white button with muted text ("This Month", "See All").
class OutlinedPill extends StatelessWidget {
  const OutlinedPill({
    super.key,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 35,
          padding: EdgeInsets.fromLTRB(12, 0, trailing == null ? 12 : 10, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.style(14, color: AppColors.textMuted)),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact button used inside cards ("Fund Wallet", "View More", "Pay Now").
class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: Text(label, style: AppText.style(13, color: foreground)),
            ),
          ),
        ),
      ),
    );
  }
}
