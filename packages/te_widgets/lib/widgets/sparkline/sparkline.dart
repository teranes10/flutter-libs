import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Presentation format for [TSparkline].
enum TSparklineType {
  /// Thin trend line.
  line,

  /// Trend line with a gradient shaded area under the curve.
  area,

  /// Vertical micro-bars.
  bar,
}

/// A lightweight, high-performance inline sparkline chart for KPI metric tiles,
/// data table cells, and analytical dashboards.
class TSparkline extends StatelessWidget {
  /// Numerical data points.
  final List<double> data;

  /// The visual chart style: line, area, or bar. Defaults to [TSparklineType.area].
  final TSparklineType type;

  /// Primary color for the sparkline stroke or bars.
  /// If null, green is used if data ends higher than start, otherwise red/primary.
  final Color? color;

  /// Custom fill colors for area gradient.
  final List<Color>? fillGradient;

  /// Stroke width for line and area charts. Defaults to 2.0.
  final double lineWidth;

  /// Whether to apply smooth cubic bezier curve interpolation instead of straight segments. Defaults to true.
  final bool smooth;

  /// Whether to render a highlighted pulse dot on the most recent (last) data point. Defaults to true.
  final bool showEndDot;

  /// Whether to render dot indicators on the minimum and maximum data points. Defaults to false.
  final bool showMinMaxDots;

  /// Height of the sparkline canvas. Defaults to 40.0.
  final double height;

  /// Width of the sparkline canvas. Defaults to 100.0.
  final double? width;

  const TSparkline({
    super.key,
    required this.data,
    this.type = TSparklineType.area,
    this.color,
    this.fillGradient,
    this.lineWidth = 2.0,
    this.smooth = true,
    this.showEndDot = true,
    this.showMinMaxDots = false,
    this.height = 40.0,
    this.width = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(width: width, height: height);

    final isTrendingUp = data.length >= 2 && data.last >= data.first;
    final defaultColor = color ?? (isTrendingUp ? Colors.green.shade600 : Colors.red.shade600);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: data,
          type: type,
          color: defaultColor,
          fillGradient: fillGradient,
          lineWidth: lineWidth,
          smooth: smooth,
          showEndDot: showEndDot,
          showMinMaxDots: showMinMaxDots,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final TSparklineType type;
  final Color color;
  final List<Color>? fillGradient;
  final double lineWidth;
  final bool smooth;
  final bool showEndDot;
  final bool showMinMaxDots;

  _SparklinePainter({
    required this.data,
    required this.type,
    required this.color,
    this.fillGradient,
    required this.lineWidth,
    required this.smooth,
    required this.showEndDot,
    required this.showMinMaxDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    if (type == TSparklineType.bar) {
      _paintBars(canvas, size, minVal, range);
      return;
    }

    final topPadding = lineWidth + 2;
    final bottomPadding = lineWidth + 2;
    final chartHeight = size.height - topPadding - bottomPadding;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = data.length == 1 ? size.width / 2 : (i / (data.length - 1)) * size.width;
      final normalized = (data[i] - minVal) / range;
      final y = size.height - bottomPadding - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    if (smooth && points.length > 2) {
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      }
    } else {
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    // Paint Area Fill
    if (type == TSparklineType.area) {
      final fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      final defaultGradient = [
        color.withValues(alpha: 0.35),
        color.withValues(alpha: 0.0),
      ];

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fillGradient ?? defaultGradient,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Paint Line Stroke
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Paint End Dot
    if (showEndDot && points.isNotEmpty) {
      final dotPaint = Paint()..color = color;
      final haloPaint = Paint()..color = color.withValues(alpha: 0.25);

      canvas.drawCircle(points.last, lineWidth + 3, haloPaint);
      canvas.drawCircle(points.last, lineWidth + 1, dotPaint);
    }

    // Paint Min/Max Dots
    if (showMinMaxDots && points.length >= 2) {
      int minIdx = 0;
      int maxIdx = 0;
      for (int i = 0; i < data.length; i++) {
        if (data[i] < data[minIdx]) minIdx = i;
        if (data[i] > data[maxIdx]) maxIdx = i;
      }

      final maxPaint = Paint()..color = Colors.green.shade700;
      canvas.drawCircle(points[maxIdx], lineWidth + 1, maxPaint);

      final minPaint = Paint()..color = Colors.red.shade700;
      canvas.drawCircle(points[minIdx], lineWidth + 1, minPaint);
    }
  }

  void _paintBars(Canvas canvas, Size size, double minVal, double range) {
    final barPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final n = data.length;
    final totalSpacing = (n - 1) * 2.0;
    final barWidth = math.max(1.0, (size.width - totalSpacing) / n);

    for (int i = 0; i < n; i++) {
      final x = i * (barWidth + 2.0);
      final normalized = (data[i] - minVal) / range;
      final barHeight = math.max(2.0, normalized * size.height);
      final y = size.height - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.smooth != smooth;
  }
}

/// A compact percentage and directional trend indicator badge (e.g. `+14.2% ↑`).
class TTrendIndicator extends StatelessWidget {
  /// The percentage delta (e.g. 14.2 for +14.2%, -3.1 for -3.1%).
  final double delta;

  /// Optional comparison label text placed after the percentage (e.g. "vs last 30 days").
  final String? comparisonLabel;

  /// Whether positive delta is considered good (green). Defaults to true.
  /// If false, positive delta is red (e.g. for churn rate, latency, or error rates).
  final bool isPositiveGood;

  /// Whether to show directional arrows (↑ / ↓). Defaults to true.
  final bool showArrow;

  /// Whether to render inside a filled pill badge background. Defaults to true.
  final bool asPill;

  const TTrendIndicator({
    super.key,
    required this.delta,
    this.comparisonLabel,
    this.isPositiveGood = true,
    this.showArrow = true,
    this.asPill = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = delta >= 0;
    final isGood = isPositive ? isPositiveGood : !isPositiveGood;

    final Color primaryColor = isGood ? Colors.green.shade700 : Colors.red.shade700;
    final Color bgColor = primaryColor.withValues(alpha: 0.12);

    final sign = isPositive ? '+' : '';
    final arrow = showArrow ? (isPositive ? ' ↑' : ' ↓') : '';
    final formattedDelta = '$sign${delta.toStringAsFixed(1)}%$arrow';

    final textWidget = Text(
      formattedDelta,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isFinite = constraints.maxWidth.isFinite;

        final labelWidget = comparisonLabel != null
            ? Text(
                comparisonLabel!,
                style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : null;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (asPill)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: textWidget,
              )
            else
              textWidget,
            if (labelWidget != null) ...[
              const SizedBox(width: 6),
              if (isFinite)
                Flexible(child: labelWidget)
              else
                labelWidget,
            ],
          ],
        );
      },
    );
  }
}
