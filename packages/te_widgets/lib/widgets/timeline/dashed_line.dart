import 'package:flutter/material.dart';

/// The style of the connecting line.
enum TTimelineLineStyle {
  /// A dashed line consisting of dashes separated by gaps.
  dashed,

  /// A continuous solid line.
  solid,

  /// A dotted line made of small dots.
  dotted,

  /// No line is drawn.
  none,
}

/// A custom painter that draws dashed, dotted, or solid lines.
class TDashedLinePainter extends CustomPainter {
  final Axis direction;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final TTimelineLineStyle style;

  const TDashedLinePainter({
    this.direction = Axis.vertical,
    required this.color,
    this.strokeWidth = 2.0,
    this.dashLength = 5.0,
    this.dashGap = 3.5,
    this.style = TTimelineLineStyle.dashed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (style == TTimelineLineStyle.none || color.a == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = style == TTimelineLineStyle.dotted ? StrokeCap.round : StrokeCap.butt;

    if (direction == Axis.vertical) {
      final x = size.width / 2;
      final totalHeight = size.height;

      if (totalHeight <= 0) return;

      if (style == TTimelineLineStyle.solid) {
        canvas.drawLine(Offset(x, 0), Offset(x, totalHeight), paint);
        return;
      }

      final dLength = style == TTimelineLineStyle.dotted ? strokeWidth : dashLength;
      final dGap = style == TTimelineLineStyle.dotted ? (dashGap > 0 ? dashGap : strokeWidth) : dashGap;
      double currentY = 0;

      while (currentY < totalHeight) {
        final nextY = (currentY + dLength).clamp(0.0, totalHeight);
        canvas.drawLine(Offset(x, currentY), Offset(x, nextY), paint);
        currentY += dLength + dGap;
      }
    } else {
      final y = size.height / 2;
      final totalWidth = size.width;

      if (totalWidth <= 0) return;

      if (style == TTimelineLineStyle.solid) {
        canvas.drawLine(Offset(0, y), Offset(totalWidth, y), paint);
        return;
      }

      final dLength = style == TTimelineLineStyle.dotted ? strokeWidth : dashLength;
      final dGap = style == TTimelineLineStyle.dotted ? (dashGap > 0 ? dashGap : strokeWidth) : dashGap;
      double currentX = 0;

      while (currentX < totalWidth) {
        final nextX = (currentX + dLength).clamp(0.0, totalWidth);
        canvas.drawLine(Offset(currentX, y), Offset(nextX, y), paint);
        currentX += dLength + dGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant TDashedLinePainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.style != style;
  }
}

/// A standalone widget that renders a dashed or solid line.
class TDashedLine extends StatelessWidget {
  final Axis direction;
  final Color? color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final TTimelineLineStyle style;

  const TDashedLine({
    super.key,
    this.direction = Axis.vertical,
    this.color,
    this.strokeWidth = 2.0,
    this.dashLength = 5.0,
    this.dashGap = 3.5,
    this.style = TTimelineLineStyle.dashed,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.outlineVariant;

    return CustomPaint(
      painter: TDashedLinePainter(
        direction: direction,
        color: themeColor,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
        style: style,
      ),
      child: direction == Axis.vertical
          ? SizedBox(width: strokeWidth)
          : SizedBox(height: strokeWidth),
    );
  }
}
