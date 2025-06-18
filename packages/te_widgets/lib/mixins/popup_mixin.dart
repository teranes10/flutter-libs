import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

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

  BoxDecoration get dropdownDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.grey.shade50.withAlpha(100), blurRadius: 8, offset: const Offset(0, 4))],
      );

  double get _targetWidth {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  double get _targetHeight {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 200;
  }

  double get contentMaxWidth => _targetWidth;
  double get contentMaxHeight => MediaQuery.of(context).size.height * 0.85;

  Widget getContentWidget();

  void showPopup() {
    if (_widget.disabled || isPopupShowing) return;
    _showOverlay();
  }

  void hidePopup() {
    if (isPopupShowing) {
      _hideOverlay();
    }
  }

  void togglePopup() {
    isPopupShowing ? hidePopup() : showPopup();
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

  Widget _buildContentWidget() {
    return Material(
      elevation: 1,
      borderRadius: dropdownDecoration.borderRadius ?? BorderRadius.circular(8),
      child: Container(
        key: _contentKey,
        decoration: dropdownDecoration,
        child: Stack(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(3, 9, 3, 0), child: getContentWidget()),
            Positioned(top: 2, right: 2, child: CloseIconButton(size: 14, onClose: hidePopup)),
          ],
        ),
      ),
    );
  }

  void _showOverlay() {
    if (shouldCenterOnSmallScreen) {
      _showCenteredOverlay();
    } else {
      _showAnchoredOverlay();
    }
  }

  void _showCenteredOverlay() {
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (!persistent)
            Positioned.fill(
              child: GestureDetector(
                onTap: hidePopup,
                child: Container(color: AppColors.grey[950]!.withAlpha(10)),
              ),
            ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenSize.width * 0.85,
                maxHeight: screenSize.height * 0.85,
              ),
              child: _buildContentWidget(),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _isOverlayVisible = true;
    _widget.onShow?.call();
  }

  void _showAnchoredOverlay() {
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
              child: SingleChildScrollView(child: _buildContentWidget()),
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
    hidePopup();
    super.dispose();
  }
}
