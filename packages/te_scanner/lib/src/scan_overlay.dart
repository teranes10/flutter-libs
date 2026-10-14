import 'package:flutter/material.dart';

/// Dimmed overlay with a rounded cut-out around the scan window.
class ScanOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  ScanOverlayPainter({required this.scanWindow, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)));

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(Path.combine(PathOperation.difference, backgroundPath, cutoutPath), paint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanWindow != scanWindow || oldDelegate.borderRadius != borderRadius;
}

/// Animated red scan line sweeping the scan window.
class ScanningLine extends AnimatedWidget {
  final Rect scanWindow;
  const ScanningLine({super.key, required Animation<double> animation, required this.scanWindow}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final top = scanWindow.top + (scanWindow.height * animation.value);
    return Positioned(
      top: top,
      left: scanWindow.left + 8,
      width: scanWindow.width - 16,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 2)],
          color: Colors.red,
        ),
      ),
    );
  }
}
