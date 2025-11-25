import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TPopupAlignment {
  bottomLeft,
  bottomRight,
  topLeft,
  topRight,
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
}

mixin TPopupMixin {
  bool get disabled;
  TPopupAlignment get alignment => TPopupAlignment.bottomLeft;
  double get offset => 8;
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

  bool get persistent => false;
  bool get isPopupShowing => _overlayEntry != null && _isOverlayVisible;
  bool get shouldCenteredOverlay => MediaQuery.of(context).isMobile;

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
  double get contentMaxHeight => MediaQuery.of(context).size.height;

  ({double maxWidth, double maxHeight, FractionalOffset alignment}) get contentConstraints {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final viewInsets = mediaQuery.viewInsets;

    final keyboardHeight = viewInsets.bottom;
    final availableWidth = mediaQuery.isMobile ? screenSize.width - 25 : screenSize.width * 0.85;
    final availableHeight = mediaQuery.isMobile ? screenSize.height - keyboardHeight - 25 : screenSize.height * 0.85;
    final alignment = mediaQuery.isMobile ? const FractionalOffset(0.5, 0.05) : const FractionalOffset(0.5, 0.1);

    return (
      maxWidth: contentMaxWidth.clamp(100.0, availableWidth),
      maxHeight: contentMaxHeight.clamp(100.0, availableHeight),
      alignment: alignment,
    );
  }

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
      child: KeyedSubtree(key: _dropdownTargetKey, child: child),
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
            Positioned(top: 2, right: 2, child: TIcon.close(colors, size: 20, onTap: hidePopup)),
          ],
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    if (shouldCenteredOverlay) {
      _showCenteredOverlay(context);
    } else {
      _showAnchoredOverlay(context);
    }
  }

  void _showCenteredOverlay(BuildContext context) {
    final colors = context.colors;
    final constraints = contentConstraints;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (!persistent) Positioned.fill(child: GestureDetector(onTap: hidePopup, child: Container(color: colors.scrim))),
          Align(
            alignment: constraints.alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth, maxHeight: constraints.maxHeight),
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
    final constraints = contentConstraints;

    final position = _calculateDropdownPosition(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
    );

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
            targetAnchor: position.targetAnchor,
            followerAnchor: position.followerAnchor,
            offset: position.offset,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
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

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
    _widget.onHide?.call();
  }

  @override
  void dispose() {
    if (isPopupShowing) hidePopup();
    super.dispose();
  }

  ({Alignment targetAnchor, Alignment followerAnchor, Offset offset}) _calculateDropdownPosition({
    required double width,
    required double height,
  }) {
    final renderBox = _dropdownTargetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return (
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: Offset(0, _widget.offset),
      );
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    final spaceBelow = screenSize.height - (position.dy + _targetHeight);
    final spaceAbove = position.dy;
    final spaceRight = screenSize.width - (position.dx + _targetWidth);
    final spaceLeft = position.dx;

    final requiredHeightSpace = height + _widget.offset;
    final extraWidthNeeded = width > _targetWidth ? width - _targetWidth : 0;

    final canShowBelow = spaceBelow >= requiredHeightSpace;
    final canShowAbove = spaceAbove >= requiredHeightSpace;
    final canShowRight = spaceRight >= extraWidthNeeded;
    final canShowLeft = spaceLeft >= extraWidthNeeded;

    final (openUpward, openToRight, openOnSide) = switch (_widget.alignment) {
      TPopupAlignment.bottomLeft => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          false,
        ),
      TPopupAlignment.bottomRight => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          false,
        ),
      TPopupAlignment.topLeft => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          false,
        ),
      TPopupAlignment.topRight => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          false,
        ),
      TPopupAlignment.rightTop => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          true,
        ),
      TPopupAlignment.rightBottom => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          true,
        ),
      TPopupAlignment.leftTop => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          true,
        ),
      TPopupAlignment.leftBottom => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          true,
        ),
    };

    return openOnSide ? _getSideAnchors(openToRight, openUpward) : _getVerticalAnchors(openUpward, openToRight);
  }

  ({Alignment targetAnchor, Alignment followerAnchor, Offset offset}) _getSideAnchors(bool openToRight, bool openUpward) {
    if (openToRight) {
      return openUpward
          ? (targetAnchor: Alignment.bottomRight, followerAnchor: Alignment.bottomLeft, offset: Offset(_widget.offset, 0))
          : (targetAnchor: Alignment.topRight, followerAnchor: Alignment.topLeft, offset: Offset(_widget.offset, 0));
    } else {
      return openUpward
          ? (targetAnchor: Alignment.bottomLeft, followerAnchor: Alignment.bottomRight, offset: Offset(-_widget.offset, 0))
          : (targetAnchor: Alignment.topLeft, followerAnchor: Alignment.topRight, offset: Offset(-_widget.offset, 0));
    }
  }

  ({Alignment targetAnchor, Alignment followerAnchor, Offset offset}) _getVerticalAnchors(bool openUpward, bool openToRight) {
    if (openUpward) {
      return openToRight
          ? (targetAnchor: Alignment.topLeft, followerAnchor: Alignment.bottomLeft, offset: Offset(0, -_widget.offset))
          : (targetAnchor: Alignment.topRight, followerAnchor: Alignment.bottomRight, offset: Offset(0, -_widget.offset));
    } else {
      return openToRight
          ? (targetAnchor: Alignment.bottomLeft, followerAnchor: Alignment.topLeft, offset: Offset(0, _widget.offset))
          : (targetAnchor: Alignment.bottomRight, followerAnchor: Alignment.topRight, offset: Offset(0, _widget.offset));
    }
  }
}
