import 'package:flutter/material.dart';
import 'package:te_widgets/extensions/media_query_data_x.dart';

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
    final maxWidth =
        (inputConstraints.maxWidth == double.infinity ? viewportSize.width : inputConstraints.maxWidth).clamp(minWidth, viewportSize.width);
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
    final requiredWidthSpace = contentWidth + offset;
    final extraWidthNeeded = contentWidth > targetSize.width ? contentWidth - targetSize.width : 0.0;
    final extraHeightNeeded = contentHeight > targetSize.height ? contentHeight - targetSize.height : 0.0;

    // For openOnSide = false (top/bottom)
    final canShowBelowTB = spaceBelow >= requiredHeightSpace;
    final canShowAboveTB = spaceAbove >= requiredHeightSpace;
    final canShowRightTB = spaceRight >= extraWidthNeeded;
    final canShowLeftTB = spaceLeft >= extraWidthNeeded;

    // For openOnSide = true (left/right)
    final canShowRightLR = spaceRight >= requiredWidthSpace;
    final canShowLeftLR = spaceLeft >= requiredWidthSpace;
    final canShowBelowLR = spaceBelow >= extraHeightNeeded;
    final canShowAboveLR = spaceAbove >= extraHeightNeeded;

    final (openUpward, openToRight, openOnSide, isCentered) = switch (alignment) {
      TPopupAlignment.bottomLeft => (
          canShowBelowTB ? false : (canShowAboveTB ? true : spaceAbove > spaceBelow),
          canShowRightTB ? true : (canShowLeftTB ? false : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.bottomRight => (
          canShowBelowTB ? false : (canShowAboveTB ? true : spaceAbove > spaceBelow),
          canShowLeftTB ? false : (canShowRightTB ? true : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.bottomCenter => (
          canShowBelowTB ? false : (canShowAboveTB ? true : spaceAbove > spaceBelow),
          true,
          false,
          true,
        ),
      TPopupAlignment.topLeft => (
          canShowAboveTB ? true : (canShowBelowTB ? false : spaceAbove > spaceBelow),
          canShowRightTB ? true : (canShowLeftTB ? false : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.topRight => (
          canShowAboveTB ? true : (canShowBelowTB ? false : spaceAbove > spaceBelow),
          canShowLeftTB ? false : (canShowRightTB ? true : spaceRight > spaceLeft),
          false,
          false,
        ),
      TPopupAlignment.topCenter => (
          canShowAboveTB ? true : (canShowBelowTB ? false : spaceAbove > spaceBelow),
          true,
          false,
          true,
        ),
      TPopupAlignment.rightTop => (
          canShowBelowLR ? false : (canShowAboveLR ? true : spaceAbove > spaceBelow),
          canShowRightLR ? true : (canShowLeftLR ? false : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.rightBottom => (
          canShowAboveLR ? true : (canShowBelowLR ? false : spaceAbove > spaceBelow),
          canShowRightLR ? true : (canShowLeftLR ? false : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.rightCenter => (
          canShowRightLR ? true : (canShowLeftLR ? false : spaceRight > spaceLeft),
          true,
          true,
          true,
        ),
      TPopupAlignment.leftTop => (
          canShowBelowLR ? false : (canShowAboveLR ? true : spaceAbove > spaceBelow),
          canShowLeftLR ? false : (canShowRightLR ? true : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.leftBottom => (
          canShowAboveLR ? true : (canShowBelowLR ? false : spaceAbove > spaceBelow),
          canShowLeftLR ? false : (canShowRightLR ? true : spaceRight > spaceLeft),
          true,
          false,
        ),
      TPopupAlignment.leftCenter => (
          canShowLeftLR ? false : (canShowRightLR ? true : spaceRight > spaceLeft),
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
