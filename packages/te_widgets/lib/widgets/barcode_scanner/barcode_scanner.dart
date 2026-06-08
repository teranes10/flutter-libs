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
class TBarcodeScanner extends StatefulWidget implements TPopupMixin {
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

  final double? width;
  final double? height;
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
      this.width,
      this.height,
      this.padding = const EdgeInsets.all(12)});

  @override
  State<TBarcodeScanner> createState() => _TBarcodeScannerState();
}

class _TBarcodeScannerState extends State<TBarcodeScanner> with TPopupStateMixin<TBarcodeScanner> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: false,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void showPopup(BuildContext context) {
    if (widget.disabled || isPopupShowing) return;
    super.showPopup(context);
    _controller.start();
  }

  @override
  void hidePopup() {
    if (!isPopupShowing) return;
    _controller.stop();
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
                child: MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    widget.onScanned?.call(capture);
                    if (widget.mode == TBarcodeScannerMode.autoClose) {
                      hidePopup();
                    }
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
  double get contentMinWidth => widget.width ?? 320;

  @override
  double get contentMinHeight => widget.height ?? 320;

  @override
  Widget build(BuildContext context) {
    return buildWithDropdownTarget(
      child: InkWell(
        onTap: () => togglePopup(context),
        borderRadius: BorderRadius.circular(8),
        child: widget.child,
      ),
    );
  }
}
