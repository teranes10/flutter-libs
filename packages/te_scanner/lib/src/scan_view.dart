import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:te_widgets/te_widgets.dart';

import 'scan_overlay.dart';

/// An inline (non-popup) camera scanner for task screens.
///
/// Fills its parent, shows a scan window with a sweeping line, a torch
/// toggle and an optional **Manual entry** fallback. Each distinct barcode is
/// reported once ([duplicateWindow] suppresses immediate re-reads) with a
/// success haptic.
///
/// ```dart
/// SizedBox(
///   height: 260,
///   child: TScanView(
///     onScan: (code) => handle(code),
///     onManualEntry: openManualEntry,
///   ),
/// )
/// ```
class TScanView extends StatefulWidget {
  /// Called with the barcode text (and the raw capture) of each new scan.
  final void Function(String value, BarcodeCapture capture) onScan;

  /// When set, a "Manual entry" button is shown over the viewfinder.
  final VoidCallback? onManualEntry;

  /// Pauses detection (camera keeps running), e.g. while a result is shown.
  final bool paused;

  /// Ignores the same barcode read again within this window.
  final Duration duplicateWindow;

  /// Plays [TFeedback.success] on each accepted scan.
  final bool feedback;

  /// Fraction (0-1) of the viewfinder used by the scan window.
  final double scanWindowFraction;

  /// Corner radius of the viewfinder.
  final double borderRadius;

  /// Creates an inline scanner.
  const TScanView({
    super.key,
    required this.onScan,
    this.onManualEntry,
    this.paused = false,
    this.duplicateWindow = const Duration(milliseconds: 1500),
    this.feedback = true,
    this.scanWindowFraction = 0.75,
    this.borderRadius = 16,
  });

  @override
  State<TScanView> createState() => _TScanViewState();
}

class _TScanViewState extends State<TScanView> with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _line;
  bool _torchOn = false;
  String? _lastValue;
  DateTime? _lastAt;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(torchEnabled: false, detectionSpeed: DetectionSpeed.noDuplicates, detectionTimeoutMs: 50);
    _line = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _line.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.paused) return;
    final value = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (value == null || value.isEmpty) return;

    final now = DateTime.now();
    if (value == _lastValue && _lastAt != null && now.difference(_lastAt!) < widget.duplicateWindow) return;
    _lastValue = value;
    _lastAt = now;

    if (widget.feedback) TFeedback.success();
    widget.onScan(value, capture);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = Rect.fromCenter(
            center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            width: constraints.maxWidth * widget.scanWindowFraction,
            height: constraints.maxHeight * widget.scanWindowFraction,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                scanWindow: scanWindow,
                onDetect: _onDetect,
                errorBuilder: (context, error) => ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TIcon.raw(HugeIcons.strokeRoundedHologram, color: Colors.white70, size: 40),
                        const SizedBox(height: 8),
                        Text('Camera unavailable', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
              CustomPaint(
                painter: ScanOverlayPainter(scanWindow: scanWindow, borderRadius: widget.borderRadius - 4),
              ),
              ScanningLine(animation: _line, scanWindow: scanWindow),
              if (!kIsWeb)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _RoundButton(
                    tooltip: _torchOn ? 'Torch off' : 'Torch on',
                    icon: _torchOn ? HugeIcons.strokeRoundedFlash : HugeIcons.strokeRoundedFlashOff,
                    onTap: () {
                      setState(() => _torchOn = !_torchOn);
                      _controller.toggleTorch();
                    },
                  ),
                ),
              if (widget.onManualEntry != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: TButton(
                    text: 'Manual entry',
                    icon: HugeIcons.strokeRoundedKeyboard,
                    type: TButtonType.tonal,
                    size: TSize.xl.copyWith(minW: 0),
                    onTap: widget.onManualEntry,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final dynamic icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: TIcon.raw(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
