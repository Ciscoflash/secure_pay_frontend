import 'package:flutter/widgets.dart';

/// DM Sans text styles.
///
/// The bundled font is variable, so weight and optical size are set through
/// [FontVariation]s. Optical size follows the font size ("auto" in Figma),
/// which gives large headings the tighter spacing seen in the designs.
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
