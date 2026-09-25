import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.action});
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