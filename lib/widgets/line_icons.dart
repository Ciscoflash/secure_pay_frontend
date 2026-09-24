import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
class EyeIcon extends StatelessWidget {
  const EyeIcon({super.key, this.crossedOut = true, this.size = 24});
  final bool crossedOut;
  final double size;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _EyePainter(crossedOut: crossedOut),
    );
  }
}
class _EyePainter extends CustomPainter {
  _EyePainter({required this.crossedOut});
  final bool crossedOut;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = AppColors.textPlaceholder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final eye = Path()
      ..moveTo(2.5 * s, 12 * s)
      ..cubicTo(5 * s, 6.5 * s, 8.5 * s, 4.75 * s, 12 * s, 4.75 * s)
      ..cubicTo(15.5 * s, 4.75 * s, 19 * s, 6.5 * s, 21.5 * s, 12 * s)
      ..cubicTo(19 * s, 17.5 * s, 15.5 * s, 19.25 * s, 12 * s, 19.25 * s)
      ..cubicTo(8.5 * s, 19.25 * s, 5 * s, 17.5 * s, 2.5 * s, 12 * s)
      ..close();
    canvas.drawPath(eye, paint);
    canvas.drawCircle(Offset(12 * s, 12 * s), 3.5 * s, paint);
    if (crossedOut) {
      canvas.drawLine(
        Offset(21.5 * s, 2.5 * s),
        Offset(2.5 * s, 21.5 * s),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(_EyePainter oldDelegate) =>
      oldDelegate.crossedOut != crossedOut;
}
class ChevronDownIcon extends StatelessWidget {
  const ChevronDownIcon({super.key, this.size = 16});
  final double size;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _ChevronPainter());
  }
}
class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 16;
    final paint = Paint()
      ..color = AppColors.textPlaceholder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(3 * s, 6 * s)
        ..lineTo(8 * s, 10.5 * s)
        ..lineTo(13 * s, 6 * s),
      paint,
    );
  }
  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => false;
}
