import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Hugeicons (stroke) glyphs bundled under `assets/icons/`, plus [help],
/// which is the PNG exported from the design.
enum AppIcons {
  dashboard,
  shipments,
  services,
  notifications,
  wallet,
  addresses,
  invite,
  help,
  logout,
  truck,
  stopwatch,
  arrowUp,
  arrowDown,
  chevronUp,
  chevronDown;

  bool get _isRaster => this == help;

  String get _asset => switch (this) {
    help => 'assets/icons/help.png',
    arrowUp => 'assets/icons/arrow_up.svg',
    arrowDown => 'assets/icons/arrow_down.svg',
    chevronUp => 'assets/icons/chevron_up.svg',
    chevronDown => 'assets/icons/chevron_down.svg',
    _ => 'assets/icons/$name.svg',
  };
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, required this.color});

  final AppIcons icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (icon._isRaster) {
      // Tinted like the SVGs so hover/selected colors still apply.
      return Image.asset(
        icon._asset,
        width: size,
        height: size,
        color: color,
        colorBlendMode: BlendMode.srcIn,
        filterQuality: FilterQuality.medium,
      );
    }
    return SvgPicture.asset(
      icon._asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
