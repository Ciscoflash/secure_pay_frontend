import 'package:flutter/widgets.dart';
abstract final class AppText {
  static TextStyle style(
    double size, {
    int weight = 400,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      fontSize: size,
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        FontVariation('opsz', size.clamp(9, 40).toDouble()),
      ],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}
