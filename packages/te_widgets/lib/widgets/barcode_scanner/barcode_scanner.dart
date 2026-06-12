import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TBarcodeScannerMode {
  /// Automatically close the popup after a successful scan.
  autoClose,

  /// Keep the popup open after scanning, allowing multiple scans until the close button is pressed.
  stayOpen,
}

/// A widget that provides barcode scanning functionality within a popup.
///
/// This widget uses [TPopupMixin] to display the camera stream in a floating popup
/// instead of a full-screen view.
class TBarcodeScanner extends StatefulWidget with TPopupMixin {
  /// The widget that triggers the scanner popup when tapped.
  final Widget child;

  /// Callback fired when a barcode is successfully scanned.
  final void Function(BarcodeCapture capture)? onScanned;

  /// The scanning mode.
  ///
  /// Defaults to [TBarcodeScannerMode.autoClose].
  final TBarcodeScannerMode mode;

  /// The title displayed at the top of the scanner popup.
  final String? title;

  @override
  final bool disabled;

  @override
  final TPopupAlignment alignment;

  @override
  final double offset;

  @override
  final VoidCallback? onShow;

  @override
  final VoidCallback? onHide;

  final double width;
  final double height;
  final EdgeInsets padding;

  const TBarcodeScanner(
      {super.key,
      required this.child,
      this.onScanned,
      this.mode = TBarcodeScannerMode.autoClose,
      this.title,
      this.disabled = false,
      this.alignment = TPopupAlignment.bottomLeft,
      this.offset = 8,
      this.onShow,
      this.onHide,
      this.width = 350,
      this.height = 350,
      this.padding = const EdgeInsets.all(12)});

  @override
  State<TBarcodeScanner> createState() => _TBarcodeScannerState();
}

class _TBarcodeScannerState extends State<TBarcodeScanner> with TPopupStateMixin<TBarcodeScanner>, SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _animationController;
  bool _isTorchOn = false;
  double _zoomScale = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: false,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 50,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void showPopup(BuildContext context) async {
    if (widget.disabled || isPopupShowing) return;
    await _controller.start();
    if (!context.mounted) return;
    super.showPopup(context);
  }

  @override
  void hidePopup() {
    if (!isPopupShowing) return;
    _controller.stop();
    setState(() {
      _isTorchOn = false;
      _zoomScale = 0.0;
    });
    super.hidePopup();
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title != null)
            Padding(
              padding: EdgeInsets.only(left: 6, bottom: widget.padding.bottom / 2),
              child: Text(
                widget.title!,
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scanWindow = Rect.fromCenter(
                      center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
                      width: constraints.maxWidth * 0.7,
                      height: constraints.maxHeight * 0.7,
                    );

                    return Stack(
                      children: [
                        MobileScanner(
                          controller: _controller,
                          scanWindow: scanWindow,
                          onDetect: (capture) {
                            widget.onScanned?.call(capture);
                            if (widget.mode == TBarcodeScannerMode.autoClose) {
                              hidePopup();
                            }
                          },
                          errorBuilder: (context, error, child) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    error.errorCode.name,
                                    style: context.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        CustomPaint(
                          painter: _ScannerOverlayPainter(
                            scanWindow: scanWindow,
                            borderRadius: 12,
                          ),
                        ),
                        _ScanningLine(
                          animation: _animationController,
                          scanWindow: scanWindow,
                        ),
                        if (!kIsWeb)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                TIcon(
                                  icon: _zoomScale > 0 ? Icons.zoom_out : Icons.zoom_in,
                                  onTap: () {
                                    setState(() {
                                      _zoomScale = _zoomScale > 0 ? 0.0 : 0.5;
                                    });
                                    _controller.setZoomScale(_zoomScale);
                                  },
                                  background: Colors.black.withValues(alpha: 0.5),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                TIcon(
                                  icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                                  onTap: () {
                                    setState(() {
                                      _isTorchOn = !_isTorchOn;
                                    });
                                    _controller.toggleTorch();
                                  },
                                  background: Colors.black.withValues(alpha: 0.5),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                TIcon(
                                  icon: Icons.flip_camera_ios,
                                  onTap: () => _controller.switchCamera(),
                                  background: Colors.black.withValues(alpha: 0.5),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.mode == TBarcodeScannerMode.stayOpen)
            Padding(
              padding: EdgeInsets.only(top: widget.padding.top / 2),
              child: TButton(
                text: 'Done',
                onTap: hidePopup,
                type: TButtonType.solid,
              ),
            ),
        ],
      ),
    );
  }

  @override
  double get contentMinWidth => widget.width;

  @override
  double get contentMinHeight => widget.height;

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: KeyedSubtree(
        key: GlobalKey(),
        child: InkWell(
          onTap: () => togglePopup(context),
          borderRadius: BorderRadius.circular(8),
          child: widget.child,
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;

  _ScannerOverlayPainter({required this.scanWindow, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)));

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanWindow != scanWindow || oldDelegate.borderRadius != borderRadius;
}

class _ScanningLine extends AnimatedWidget {
  final Rect scanWindow;
  const _ScanningLine({
    required Animation<double> animation,
    required this.scanWindow,
  }) : super(listenable: animation);

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
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
          color: Colors.red,
        ),
      ),
    );
  }
}
