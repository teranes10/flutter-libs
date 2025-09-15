import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:te_widgets/widgets/close-icon/close_icon.dart';

mixin TPopupMixin {
  bool get disabled;
  VoidCallback? get onShow;
  VoidCallback? get onHide;
}

mixin TPopupStateMixin<T extends StatefulWidget> on State<T> {
  late final TPopupMixin _widget = widget as TPopupMixin;

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownTargetKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  bool _openUpward = false;

  bool get persistent => false;
  bool get isPopupShowing => _overlayEntry != null && _isOverlayVisible;
  bool get shouldCenterOnSmallScreen => MediaQuery.of(context).size.width <= 600;

  BoxDecoration getDropdownDecoration(ColorScheme colors) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.outline),
      color: colors.surface,
      boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 12, spreadRadius: 0)],
    );
  }

  double get _targetWidth {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  double get _targetHeight {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 200;
  }

  double get contentMaxWidth => _targetWidth;
  double get contentMaxHeight => MediaQuery.of(context).size.height - 25;

  Widget getContentWidget(BuildContext context);

  void showPopup(BuildContext context) {
    if (_widget.disabled || isPopupShowing) return;
    _showOverlay(context);
  }

  void hidePopup() {
    if (isPopupShowing) {
      _hideOverlay();
    }
  }

  void togglePopup(BuildContext context) {
    isPopupShowing ? hidePopup() : showPopup(context);
  }

  void rebuildPopup() {
    if (!mounted || !isPopupShowing) return;
    _overlayEntry?.markNeedsBuild();
  }

  Widget buildWithDropdownTarget({required Widget child}) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(key: _dropdownTargetKey, child: child),
    );
  }

  Widget _buildContentWidget(BuildContext context) {
    final colors = context.colors;
    final dropdownDecoration = getDropdownDecoration(colors);

    return Material(
      elevation: 1,
      borderRadius: dropdownDecoration.borderRadius ?? BorderRadius.circular(8),
      child: Container(
        key: _contentKey,
        decoration: dropdownDecoration,
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(3, 9, 3, 0), child: getContentWidget(context)),
            Positioned(top: 2, right: 2, child: TCloseIcon(size: 18, onClose: hidePopup)),
          ],
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    if (shouldCenterOnSmallScreen) {
      _showCenteredOverlay(context);
    } else {
      _showAnchoredOverlay(context);
    }
  }

  void _showCenteredOverlay(BuildContext context) {
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final viewInsets = mediaQuery.viewInsets;

    final keyboardHeight = viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    final availableHeight = screenSize.height - keyboardHeight;

    final alignment = isKeyboardOpen ? const FractionalOffset(0.5, 0.1) : const FractionalOffset(0.5, 0.275);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (!persistent) Positioned.fill(child: GestureDetector(onTap: hidePopup, child: Container(color: colors.scrim))),
          Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: screenSize.width - 25, maxHeight: isKeyboardOpen ? availableHeight - 25 : screenSize.height - 25),
              child: _buildContentWidget(context),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _isOverlayVisible = true;
    _widget.onShow?.call();
  }

  void _showAnchoredOverlay(BuildContext context) {
    _calculateDropdownPosition();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (!persistent)
            Positioned.fill(
              child: GestureDetector(
                onTap: hidePopup,
                child: Container(color: Colors.transparent),
              ),
            ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: _openUpward ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor: _openUpward ? Alignment.bottomLeft : Alignment.topLeft,
            offset: _openUpward ? const Offset(0, -8) : const Offset(0, 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: contentMaxWidth,
                maxHeight: contentMaxHeight,
              ),
              child: SingleChildScrollView(child: _buildContentWidget(context)),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _isOverlayVisible = true;
    _widget.onShow?.call();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
    _widget.onHide?.call();
  }

  void _calculateDropdownPosition() {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (position.dy + _targetHeight);
    final spaceAbove = position.dy;

    final estimatedPopupHeight = _getEstimatedPopupHeight();
    final requiredSpace = estimatedPopupHeight + 16;

    if (spaceBelow < requiredSpace && spaceAbove >= requiredSpace) {
      _openUpward = true;
    } else if (spaceBelow >= requiredSpace) {
      _openUpward = false;
    } else {
      _openUpward = spaceAbove > spaceBelow;
    }
  }

  double _getEstimatedPopupHeight() {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxAllowedHeight = screenHeight * 0.85;

    return contentMaxHeight.clamp(100.0, maxAllowedHeight);
  }

  @override
  void dispose() {
    if (isPopupShowing) hidePopup();
    super.dispose();
  }
}
