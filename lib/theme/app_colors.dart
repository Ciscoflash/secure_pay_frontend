import 'package:flutter/material.dart';

/// Color tokens sampled from the auth screen designs in `/design`.
abstract final class AppColors {
  static const primary = Color(0xFF5C65A6);
  static const primaryLight = Color(0xFF787FB6);
  static const primaryDark = Color(0xFF4F5894);

  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF171717);
  static const textSecondary = Color(0xFF525252);
  static const textPlaceholder = Color(0xFFA3A3A3);

  static const border = Color(0xFFD4D4D4);
  static const error = Color(0xFFDC2626);

  // Dashboard tokens, sampled from `/design/dashboard.png`.
  static const navy = Color(0xFF272A46);
  static const navyButton = Color(0xFF33385B);
  static const textMuted = Color(0xFF737373);
  static const textLabel = Color(0xFF888888);
  static const divider = Color(0xFFE8E8E8);
  static const cardBorder = Color(0xFFEFEDED);
  static const rowDivider = Color(0xFFF4F3F3);
  static const outline = Color(0xFFEEEEEE);
  static const dotInactive = Color(0xFFD4D4D4);
  static const success = Color(0xFF3F8329);

  static const chartText = Color(0xFF1F2938);
  static const chartMuted = Color(0xFF687083);
  static const chartAxis = Color(0xFF98A2B3);
  static const chartGrid = Color(0xFFEBEDF1);
  static const chartBorder = Color(0xFFEAECF0);
  static const segmentTrack = Color(0xFFF2F4F7);
}
