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

/// Display mode options for a popup.
enum TPopupMode {
  anchored,
  centered,
  page,
}

class TPopupConstraints {
  final Size screenSize;
  final Size targetSize;
  final Offset targetOffset;
  final BoxConstraints contentBox;
  final Alignment contentAlignment;

  const TPopupConstraints({
    required this.screenSize,
    required this.targetSize,
    required this.targetOffset,
    required this.contentBox,
    required this.contentAlignment,
  });

  factory TPopupConstraints.calculate(
    BuildContext context, {
    required Size targetSize,
    required Matrix4 transform,
    required BoxConstraints inputConstraints,
    Alignment? alignment,
    double defaultSize = 100.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // Accurate position of the trigger relative to the Overlay using the provided layoutInfo
    final targetOffset = MatrixUtils.transformPoint(transform, Offset.zero);

    // Get the actual size of the Overlay to ensure correct space calculations
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final overlaySize = overlay?.size ?? mediaQuery.size;
    final viewportSize = Size(overlaySize.width, overlaySize.height - keyboardHeight);

    // Clip constraints to screen size to prevent clipping/overflow
    final minWidth = inputConstraints.minWidth.clamp(defaultSize, viewportSize.width);
    final minHeight = inputConstraints.minHeight.clamp(defaultSize, viewportSize.height);
    final maxWidth = (inputConstraints.maxWidth == double.infinity ? viewportSize.width : inputConstraints.maxWidth)
        .clamp(minWidth, viewportSize.width);
    final maxHeight = (inputConstraints.maxHeight == double.infinity ? viewportSize.height : inputConstraints.maxHeight)
        .clamp(minHeight, viewportSize.height);

    return TPopupConstraints(
      screenSize: viewportSize,
      targetSize: targetSize,
      targetOffset: targetOffset,
      contentBox: BoxConstraints(minWidth: minWidth, minHeight: minHeight, maxWidth: maxWidth, maxHeight: maxHeight),
      contentAlignment: alignment ?? (mediaQuery.isMobile ? const FractionalOffset(0.5, 0.05) : const FractionalOffset(0.5, 0.1)),
    );
  }
}

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

  /// Preferred display mode of the popup.
  TPopupMode? get popupMode => null;
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

  /// The effective display mode of the popup.
  TPopupMode get effectivePopupMode {
    final mode = _widget.popupMode;
    if (mode != null) return mode;
    final isMobile = MediaQuery.of(context).isMobile;
    if (isMobile && (widget is TSelect || widget is TMultiSelect)) {
      return TPopupMode.page;
    }
    return isMobile ? TPopupMode.centered : TPopupMode.anchored;
  }

  /// Whether to use centered overlay mode.
  bool get shouldCenteredOverlay => effectivePopupMode == TPopupMode.centered;

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

  /// Dynamic page title for page mode.
  String get popupTitle {
    if (widget is TInputFieldMixin) {
      return (widget as TInputFieldMixin).label ?? 'Select';
    }
    return 'Select';
  }

  /// Shows the popup.
  void showPopup(BuildContext context) {
    if (_widget.disabled || isPopupShowing) return;
    if (effectivePopupMode == TPopupMode.page) {
      _isOverlayVisible = true;
      _widget.onShow?.call();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => TPageWrapper(
            title: popupTitle,
            onBackPressed: () {
              hidePopup();
            },
            child: getContentWidget(ctx),
          ),
        ),
      ).then((_) {
        if (mounted && _isOverlayVisible) {
          setState(() {
            _isOverlayVisible = false;
          });
          _widget.onHide?.call();
        }
      });
    } else {
      _overlayController.show();
      _isOverlayVisible = true;
      _widget.onShow?.call();
    }
  }

  /// Hides the popup.
  void hidePopup() {
    if (!isPopupShowing) return;
    if (effectivePopupMode == TPopupMode.page) {
      _isOverlayVisible = false;
      Navigator.of(context).pop();
    } else {
      _overlayController.hide();
      _isOverlayVisible = false;
      _widget.onHide?.call();
    }
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
        final constraints = TPopupConstraints.calculate(
          context,
          targetSize: layoutInfo.childSize,
          transform: layoutInfo.childPaintTransform,
          inputConstraints: BoxConstraints(
            minWidth: contentMinWidth,
            minHeight: contentMinHeight,
            maxWidth: contentMaxWidth ?? layoutInfo.childSize.width,
            maxHeight: contentMaxHeight ?? double.infinity,
          ),
          defaultSize: _defaultSize,
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
            if (_widget.showCloseButton)
              Positioned(top: 0, right: 0, child: TIcon.close(size: 20, padding: EdgeInsets.all(5), onTap: hidePopup)),
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
