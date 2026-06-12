import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Alignment options for the popup relative to its target.
enum TPopupAlignment {
  bottomLeft,
  bottomRight,
  bottomCenter,
  topLeft,
  topRight,
  topCenter,
  leftTop,
  leftBottom,
  leftCenter,
  rightTop,
  rightBottom,
  rightCenter,
}

typedef TPopupConstraints = ({
  Size screenSize,
  Size targetSize,
  Offset targetOffset,
  BoxConstraints contentBox,
  FractionalOffset contentAlignment
});

/// Mixin for widgets that display a popup or dropdown.
mixin TPopupMixin {
  /// Whether the popup is disabled.
  bool get disabled;

  /// Preferred alignment of the popup.
  TPopupAlignment get alignment => TPopupAlignment.bottomLeft;

  /// Offset from the target widget.
  double get offset => 8;

  /// Whether to show a close button in the popup.
  bool get showCloseButton => true;

  /// Callback when popup shows.
  VoidCallback? get onShow;

  /// Callback when popup hides.
  VoidCallback? get onHide;
}

/// State mixin for managing popup overlay logic.
///
/// Handles overlay creation, positioning, and dismissal.
mixin TPopupStateMixin<T extends StatefulWidget> on State<T> {
  late final TPopupMixin _widget = widget as TPopupMixin;

  final OverlayPortalController _overlayController = OverlayPortalController();

  final GlobalKey _dropdownTargetKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();

  bool _isOverlayVisible = false;

  /// Whether the popup persists when tapping outside (defaults to false).
  bool get persistent => false;

  /// Whether the popup is currently visible.
  bool get isPopupShowing => _isOverlayVisible;

  /// Whether to use centered overlay mode (e.g. for mobile).
  bool get shouldCenteredOverlay => MediaQuery.of(context).isMobile;

  static const _defaultSize = 100.0;

  /// Minimum width of the popup content.
  double get contentMinWidth => _defaultSize;

  /// Minimum height of the popup content.
  double get contentMinHeight => _defaultSize;

  /// Maximum width of the popup content.
  double? get contentMaxWidth => null;

  /// Maximum height of the popup content.
  double? get contentMaxHeight => null;

  /// Returns the content widget to display in the popup.
  Widget getContentWidget(BuildContext context);

  /// Shows the popup.
  void showPopup(BuildContext context) {
    if (_widget.disabled || isPopupShowing) return;
    _overlayController.show();
    _isOverlayVisible = true;
    _widget.onShow?.call();
  }

  /// Hides the popup.
  void hidePopup() {
    if (!isPopupShowing) return;
    _overlayController.hide();
    _isOverlayVisible = false;
    _widget.onHide?.call();
  }

  /// Toggles popup visibility.
  void togglePopup(BuildContext context) {
    isPopupShowing ? hidePopup() : showPopup(context);
  }

  /// Forces a rebuild of the popup if it is open.
  void rebuildPopup() {
    if (!mounted || !isPopupShowing) return;
    setState(() {});
  }

  /// Wraps the child widget with an [OverlayPortal] anchored to the trigger.
  ///
  /// Call this instead of the old [buildWithDropdownTarget].  The returned
  /// widget is the trigger itself; the overlay child is built lazily via
  /// [overlayChildLayoutBuilder] and positioned without any
  /// [CompositedTransformTarget] / [CompositedTransformFollower].
  Widget buildWithDropdownTarget({required Widget child}) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayController,
      overlayChildBuilder: (ctx, layoutInfo) {
        final mediaQuery = MediaQuery.of(context);
        final screenSize = mediaQuery.size;
        final viewInsets = mediaQuery.viewInsets;
        final keyboardHeight = viewInsets.bottom;
        final targetSize = layoutInfo.childSize;
        final translation = layoutInfo.childPaintTransform.getTranslation();

        final availableWidth = mediaQuery.isMobile ? screenSize.width - 25 : screenSize.width * 0.85;
        final availableHeight = mediaQuery.isMobile ? screenSize.height - keyboardHeight - 25 : screenSize.height * 0.85;
        final safeAvailableWidth = availableWidth < _defaultSize ? _defaultSize : availableWidth;
        final safeAvailableHeight = availableHeight < _defaultSize ? _defaultSize : availableHeight;
        final alignment = mediaQuery.isMobile ? const FractionalOffset(0.5, 0.05) : const FractionalOffset(0.5, 0.1);

        final minWidth = contentMinWidth.clamp(_defaultSize, safeAvailableWidth);
        final minHeight = contentMinHeight.clamp(_defaultSize, safeAvailableHeight);
        final maxWidth = (contentMaxWidth ?? targetSize.width).clamp(minWidth, safeAvailableWidth);
        final maxHeight = (contentMaxHeight ?? screenSize.height).clamp(minHeight, safeAvailableHeight);

        TPopupConstraints constraints = (
          screenSize: screenSize,
          targetSize: layoutInfo.childSize,
          targetOffset: Offset(translation.x, translation.y),
          contentBox: BoxConstraints(minWidth: minWidth, minHeight: minHeight, maxWidth: maxWidth, maxHeight: maxHeight),
          contentAlignment: alignment,
        );

        return shouldCenteredOverlay ? buildCenteredOverlayChild(context, constraints) : buildAnchoredOverlayChild(context, constraints);
      },
      child: KeyedSubtree(key: _dropdownTargetKey, child: child),
    );
  }

  Widget buildCenteredOverlayChild(BuildContext context, TPopupConstraints constraints) {
    return Stack(
      children: [
        if (!persistent)
          Positioned.fill(child: GestureDetector(onTap: hidePopup, child: Container(color: Theme.of(context).dialogTheme.barrierColor))),
        Align(
          alignment: constraints.contentAlignment,
          child: ConstrainedBox(
            constraints: constraints.contentBox,
            child: buildContentWidget(context),
          ),
        ),
      ],
    );
  }

  Widget buildAnchoredOverlayChild(BuildContext context, TPopupConstraints constraints) {
    return Stack(
      children: [
        if (!persistent) Positioned.fill(child: GestureDetector(onTap: hidePopup, child: Container(color: Colors.transparent))),
        CustomSingleChildLayout(
          delegate: PopupPositionDelegate(
            constraints: constraints,
            alignment: _widget.alignment,
            offset: _widget.offset,
          ),
          child: ConstrainedBox(
            constraints: constraints.contentBox,
            child: buildContentWidget(context),
          ),
        ),
      ],
    );
  }

  Widget buildContentWidget(BuildContext context) {
    return TCard(
      elevation: 8,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        key: _contentKey,
        child: Stack(
          children: [
            getContentWidget(context),
            if (_widget.showCloseButton) Positioned(top: 0, right: 0, child: TIcon.close(size: 20, padding: EdgeInsets.all(5), onTap: hidePopup)),
          ],
        ),
      ),
    );
  }
}

class PopupPositionDelegate extends SingleChildLayoutDelegate {
  const PopupPositionDelegate({
    required this.constraints,
    required this.alignment,
    required this.offset,
  });

  final TPopupConstraints constraints;
  final TPopupAlignment alignment;
  final double offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return this.constraints.contentBox;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final targetOffset = constraints.targetOffset;
    final targetSize = constraints.targetSize;
    final screenSize = constraints.screenSize;
    final contentWidth = childSize.width; // actual rendered width
    final contentHeight = childSize.height; // actual rendered height

    final spaceBelow = screenSize.height - (targetOffset.dy + targetSize.height);
    final spaceAbove = targetOffset.dy;
    final spaceRight = screenSize.width - (targetOffset.dx + targetSize.width);
    final spaceLeft = targetOffset.dx;

    final requiredHeightSpace = contentHeight + offset;
    final extraWidthNeeded = contentWidth > targetSize.width ? contentWidth - targetSize.width : 0.0;

    final canShowBelow = spaceBelow >= requiredHeightSpace;
    final canShowAbove = spaceAbove >= requiredHeightSpace;
    final canShowRight = spaceRight >= extraWidthNeeded;
    final canShowLeft = spaceLeft >= extraWidthNeeded;

    final (openUpward, openToRight, openOnSide, isCentered) = switch (alignment) {
      TPopupAlignment.bottomLeft => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.bottomRight => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.bottomCenter => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          true,
          false,
          true,
        ),
      TPopupAlignment.topLeft => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.topRight => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.topCenter => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          true,
          false,
          true,
        ),
      TPopupAlignment.rightTop => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.rightBottom => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.rightCenter => (
          canShowRight ? true : (canShowLeft ? false : spaceRight > spaceLeft),
          true,
          true,
          true,
        ),
      TPopupAlignment.leftTop => (
          canShowBelow ? false : (canShowAbove ? true : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.leftBottom => (
          canShowAbove ? true : (canShowBelow ? false : spaceAbove > spaceBelow),
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.leftCenter => (
          canShowLeft ? false : (canShowRight ? true : spaceRight > spaceLeft),
          false,
          true,
          true,
        ),
    };

    double dx;
    double dy;

    if (openOnSide) {
      if (openToRight) {
        dx = targetOffset.dx + targetSize.width + offset;
      } else {
        dx = targetOffset.dx - contentWidth - offset;
      }

      if (isCentered) {
        dy = targetOffset.dy + (targetSize.height / 2) - (contentHeight / 2);
      } else if (openUpward) {
        dy = targetOffset.dy + targetSize.height - contentHeight;
      } else {
        dy = targetOffset.dy;
      }
    } else {
      if (openUpward) {
        dy = targetOffset.dy - contentHeight - offset;
      } else {
        dy = targetOffset.dy + targetSize.height + offset;
      }

      if (isCentered) {
        dx = targetOffset.dx + (targetSize.width / 2) - (contentWidth / 2);
      } else if (openToRight) {
        dx = targetOffset.dx;
      } else {
        dx = targetOffset.dx + targetSize.width - contentWidth;
      }
    }

    // Boundary check
    dx = dx.clamp(0.0, screenSize.width - contentWidth);
    dy = dy.clamp(0.0, screenSize.height - contentHeight);

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(PopupPositionDelegate oldDelegate) {
    return oldDelegate.constraints != constraints || oldDelegate.alignment != alignment || oldDelegate.offset != offset;
  }
}
