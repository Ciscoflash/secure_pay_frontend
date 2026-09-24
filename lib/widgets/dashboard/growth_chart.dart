import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/dashboard.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import 'section_states.dart';
const _ranges = [Period.year, Period.month, Period.week];
extension on Period {
  String get tabLabel => switch (this) {
    Period.year => 'Year',
    Period.month => 'Month',
    Period.week => 'Week',
  };
}
class GrowthChartCard extends StatelessWidget {
  const GrowthChartCard({
    super.key,
    required this.values,
    required this.labels,
    required this.range,
    required this.onRangeChanged,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });
  final List<double> values;
  final List<String> labels;
  final Period range;
  final ValueChanged<Period> onRangeChanged;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  bool get _isEmpty => values.every((v) => v == 0);
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      height: 367,
      padding: const EdgeInsets.fromLTRB(20, 15, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.chartBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Company Growth',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(
                    18,
                    weight: 500,
                    color: AppColors.chartText,
                  ),
                ),
              ),
              _RangeSwitch(
                value: range,
                onChanged: onRangeChanged,
                segmentWidth: compact ? 58 : 91.5,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isLoading ? 0.4 : 1,
                  child: Semantics(
                    label: _semanticsLabel(),
                    child: CustomPaint(
                      painter: _AreaChartPainter(
                        values: values,
                        labels: labels,
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  const Center(
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (error != null && onRetry != null)
                  Center(
                    child: SectionError(message: error!, onRetry: onRetry!),
                  )
                else if (values.isNotEmpty && _isEmpty)
                  Center(
                    child: Text(
                      'No shipments in this period yet',
                      style: AppText.style(14, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _semanticsLabel() {
    if (values.isEmpty || _isEmpty) {
      return 'Company growth chart. No shipments in this period.';
    }
    final points = [
      for (var i = 0; i < values.length; i++)
        '${labels[i]}: ${values[i].round()}',
    ];
    return 'Company growth chart, shipments per '
        '${range == Period.year ? 'month' : 'day'}. ${points.join(', ')}';
  }
}
class _RangeSwitch extends StatelessWidget {
  const _RangeSwitch({
    required this.value,
    required this.onChanged,
    required this.segmentWidth,
  });
  final Period value;
  final ValueChanged<Period> onChanged;
  final double segmentWidth;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        color: AppColors.segmentTrack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final range in _ranges)
            Semantics(
              button: true,
              selected: range == value,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onChanged(range),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: segmentWidth,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: range == value
                          ? AppColors.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: range == value
                          ? const [
                              BoxShadow(
                                color: Color(0x0F101828),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      range.tabLabel,
                      style: AppText.style(
                        14,
                        weight: range == value ? 500 : 400,
                        color: range == value
                            ? AppColors.chartText
                            : AppColors.chartMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({required this.values, required this.labels});
  final List<double> values;
  final List<String> labels;
  static const _gridSteps = 5;
  static const _axisGutter = 54.0;
  static const _xLabelBand = 24.0;
  static const _minLabelSpacing = 28.0;
  static double niceMax(double max) {
    if (max <= 0) return _gridSteps.toDouble();
    final rawStep = max / _gridSteps;
    final magnitude = math
        .pow(10, (math.log(rawStep) / math.ln10).floor())
        .toDouble();
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      final step = m * magnitude;
      if (step * _gridSteps >= max) {
        return math.max(step.ceilToDouble(), 1.0) * _gridSteps;
      }
    }
    return max;
  }
  @override
  void paint(Canvas canvas, Size size) {
    final axisStyle = AppText.style(12, color: AppColors.chartAxis);
    const plotLeft = _axisGutter;
    final plotRight = size.width;
    const plotTop = 13.0;
    final plotBottom = size.height - _xLabelBand;
    final plotHeight = plotBottom - plotTop;
    final maxValue = niceMax(values.fold(0.0, math.max));
    double yFor(double v) => plotBottom - (v / maxValue) * plotHeight;
    final gridPaint = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;
    for (var i = 0; i <= _gridSteps; i++) {
      final value = maxValue * i / _gridSteps;
      final y = yFor(value).roundToDouble() + 0.5;
      if (i == 0) {
        canvas.drawLine(
          Offset(plotLeft, y),
          Offset(plotRight, y),
          Paint()
            ..color = const Color(0xFFEEF0F3)
            ..strokeWidth = 1,
        );
      } else {
        for (var x = plotLeft; x < plotRight; x += 10) {
          canvas.drawLine(
            Offset(x, y),
            Offset((x + 5).clamp(plotLeft, plotRight), y),
            gridPaint,
          );
        }
      }
      _drawText(
        canvas,
        _formatThousands(value.round()),
        axisStyle,
        Offset(plotLeft - 14, y),
        align: _Align.right,
      );
    }
    if (values.length < 2) return;
    final plotWidth = plotRight - plotLeft;
    final firstX = plotLeft + plotWidth * 0.0502;
    final lastX = plotRight - plotWidth * 0.0407;
    final step = (lastX - firstX) / (values.length - 1);
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(firstX + step * i, yFor(values[i])),
    ];
    final line = _smoothPath(points, plotTop, plotBottom);
    final area = Path.from(line)
      ..lineTo(points.last.dx, plotBottom)
      ..lineTo(points.first.dx, plotBottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, plotTop),
          Offset(0, plotBottom),
          [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0),
          ],
        ),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final every = math.max(1, (_minLabelSpacing / step).ceil());
    for (var i = 0; i < labels.length && i < points.length; i++) {
      if (i % every != 0) continue;
      _drawText(
        canvas,
        labels[i],
        axisStyle,
        Offset(points[i].dx, plotBottom + 17),
        align: _Align.center,
      );
    }
  }
  Path _smoothPath(List<Offset> points, double top, double bottom) {
    Offset clampY(Offset o) => Offset(o.dx, o.dy.clamp(top, bottom));
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      final c1 = clampY(p1 + (p2 - p0) / 6);
      final c2 = clampY(p2 - (p3 - p1) / 6);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }
  void _drawText(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset anchor, {
    required _Align align,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      _Align.right => anchor.dx - painter.width,
      _Align.center => anchor.dx - painter.width / 2,
    };
    painter.paint(canvas, Offset(dx, anchor.dy - painter.height / 2));
    painter.dispose();
  }
  static String _formatThousands(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
  @override
  bool shouldRepaint(_AreaChartPainter old) =>
      !_listEquals(old.values, values) || !_listEquals(old.labels, labels);
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
enum _Align { right, center }
