import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A security and confidentiality watermark overlay for admin dashboards, records, and reports.
///
/// `TWatermark` overlays repeated, angled text or custom branding across its child widget.
/// The overlay is wrapped in [IgnorePointer] so all child interactions (clicks, text selection,
/// form inputs, and scrolling) function completely uninterrupted.
///
/// ## Basic Usage
///
/// ```dart
/// TWatermark(
///   text: 'CONFIDENTIAL • admin@company.com',
///   child: MyDashboardView(),
/// )
/// ```
///
/// ## Multiline Watermark
///
/// ```dart
/// TWatermark(
///   lines: ['ACME CORP INTERNAL', 'John Doe (ID: 9482)', '2026-09-26 12:00 UTC'],
///   opacity: 0.15,
///   child: SensitiveDataTable(),
/// )
/// ```
class TWatermark extends StatelessWidget {
  /// The underlying widget content being protected.
  final Widget child;

  /// Single line watermark text. If [lines] is provided, this is ignored.
  final String? text;

  /// Multiple lines of watermark text displayed together in each tile.
  final List<String>? lines;

  /// Text style for the watermark. If null, a subtle dimmed style is derived from the theme.
  final TextStyle? textStyle;

  /// Diagonal rotation angle in radians. Defaults to -22 degrees (-0.384 rad).
  final double rotateAngle;

  /// Horizontal spacing between adjacent watermark tile centers. Defaults to 160.0.
  final double gapX;

  /// Vertical spacing between adjacent watermark tile centers. Defaults to 140.0.
  final double gapY;

  /// Opacity multiplier for the watermark overlay. Defaults to 0.12.
  final double opacity;

  /// Whether the watermark overlay is currently enabled and visible. Defaults to true.
  final bool enabled;

  const TWatermark({
    super.key,
    required this.child,
    this.text,
    this.lines,
    this.textStyle,
    this.rotateAngle = -22.0 * math.pi / 180.0,
    this.gapX = 160.0,
    this.gapY = 140.0,
    this.opacity = 0.12,
    this.enabled = true,
  }) : assert(text != null || lines != null, 'Either text or lines must be specified for TWatermark');

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultColor = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity);

    final resolvedStyle = (textStyle ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ))
        .copyWith(
      color: (textStyle?.color ?? defaultColor).withValues(alpha: opacity),
    );

    final effectiveLines = lines ?? (text != null ? [text!] : const <String>[]);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _WatermarkPainter(
                  lines: effectiveLines,
                  textStyle: resolvedStyle,
                  rotateAngle: rotateAngle,
                  gapX: gapX,
                  gapY: gapY,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final List<String> lines;
  final TextStyle textStyle;
  final double rotateAngle;
  final double gapX;
  final double gapY;

  _WatermarkPainter({
    required this.lines,
    required this.textStyle,
    required this.rotateAngle,
    required this.gapX,
    required this.gapY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty || size.width <= 0 || size.height <= 0) return;

    final textPainters = lines.map((line) {
      final span = TextSpan(text: line, style: textStyle);
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    }).toList();

    double maxTextWidth = 0;
    double totalTextHeight = 0;
    for (final tp in textPainters) {
      maxTextWidth = math.max(maxTextWidth, tp.width);
      totalTextHeight += tp.height + 2;
    }

    final stepX = maxTextWidth + gapX;
    final stepY = totalTextHeight + gapY;

    // Expand bounding bounds so rotated tiles near borders are fully covered
    const margin = 200.0;
    final startX = -margin;
    final endX = size.width + margin;
    final startY = -margin;
    final endY = size.height + margin;

    int rowIndex = 0;
    for (double y = startY; y < endY; y += stepY) {
      // Stagger alternate rows for natural diamond / brick layout
      final offsetX = (rowIndex % 2 == 1) ? stepX / 2 : 0.0;
      for (double x = startX + offsetX; x < endX; x += stepX) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotateAngle);

        double curY = -totalTextHeight / 2;
        for (final tp in textPainters) {
          tp.paint(canvas, Offset(-tp.width / 2, curY));
          curY += tp.height + 2;
        }

        canvas.restore();
      }
      rowIndex++;
    }

    for (final tp in textPainters) {
      tp.dispose();
    }
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.rotateAngle != rotateAngle ||
        oldDelegate.gapX != gapX ||
        oldDelegate.gapY != gapY;
  }
}
