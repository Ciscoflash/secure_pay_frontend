import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'app_icon.dart';
import 'nav_destination.dart';
class PlaceholderDestination extends StatelessWidget {
  const PlaceholderDestination({super.key, required this.destination});
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