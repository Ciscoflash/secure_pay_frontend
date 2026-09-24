import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/password_policy.dart';
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.controller});
  final TextEditingController controller;
  static const _levels = [
    ('', Colors.transparent),
    ('Weak', AppColors.error),
    ('Fair', Color(0xFFD97706)),
    ('Good', Color(0xFF65A30D)),
    ('Strong', AppColors.success),
  ];
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final password = value.text;
        if (password.isEmpty) return const SizedBox.shrink();
        final score = PasswordPolicy.strength(password);
        final (label, color) = _levels[score];
        final common = PasswordPolicy.isCommon(password);
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Password strength: $label',
                excludeSemantics: true,
                child: Row(
                  children: [
                    for (var i = 1; i <= 4; i++) ...[
                      if (i > 1) const SizedBox(width: 4),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= score ? color : const Color(0xFFE5E5E5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      child: Text(
                        label,
                        style: AppText.style(12, weight: 600, color: color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  for (final rule in PasswordPolicy.rules)
                    _Requirement(label: rule.label, met: rule.test(password)),
                  if (common)
                    const _Requirement(
                      label: 'Not a common password',
                      met: false,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
class _Requirement extends StatelessWidget {
  const _Requirement({required this.label, required this.met});
  final String label;
  final bool met;
  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.textMuted;
    return Semantics(
      label: '$label: ${met ? 'met' : 'not met'}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(label, style: AppText.style(12, color: color)),
        ],
      ),
    );
  }
}
