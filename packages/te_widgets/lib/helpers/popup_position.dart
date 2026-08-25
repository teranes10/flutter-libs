import 'dart:math' as math;
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
    TPopupAlignment popupAlignment = TPopupAlignment.bottomLeft,
    double defaultSize = 100.0,
    double margin = 30.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // Accurate position of the trigger relative to the Overlay using the provided layoutInfo
    final targetOffset = MatrixUtils.transformPoint(transform, Offset.zero);

    // Get the actual size of the Overlay to ensure correct space calculations
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final overlaySize = overlay?.size ?? mediaQuery.size;
    final effectiveHeight = math.max(0.0, overlaySize.height - keyboardHeight);
    final effectiveWidth = math.max(0.0, overlaySize.width);
    final viewportSize = Size(effectiveWidth, effectiveHeight);

    final isOpenOnSide = popupAlignment == TPopupAlignment.rightTop ||
        popupAlignment == TPopupAlignment.rightBottom ||
        popupAlignment == TPopupAlignment.rightCenter ||
        popupAlignment == TPopupAlignment.leftTop ||
        popupAlignment == TPopupAlignment.leftBottom ||
        popupAlignment == TPopupAlignment.leftCenter;

    final double spaceBelow;
    final double spaceAbove;

    if (isOpenOnSide) {
      // For side popups, top aligns with target top (downwards) or bottom aligns with target bottom (upwards)
      spaceBelow = viewportSize.height - targetOffset.dy - margin;
      spaceAbove = (targetOffset.dy + targetSize.height) - margin;
    } else {
      // For top/bottom popups, popup opens below target bottom or above target top
      spaceBelow = viewportSize.height - (targetOffset.dy + targetSize.height) - margin;
      spaceAbove = targetOffset.dy - margin;
    }

    final maxAvailableHeight = spaceAbove > spaceBelow ? spaceAbove : spaceBelow;
    final clampedAvailableHeight = maxAvailableHeight > 0
        ? math.min(viewportSize.height, math.max(defaultSize, maxAvailableHeight))
        : viewportSize.height;

    // Clip constraints to screen size and available height safely
    final maxWidth = (inputConstraints.maxWidth.isFinite
            ? math.min(inputConstraints.maxWidth, viewportSize.width)
            : viewportSize.width)
        .clamp(0.0, viewportSize.width);
    final minWidth = math.min(inputConstraints.minWidth, maxWidth).clamp(0.0, maxWidth);

    final allowedMaxHeight = inputConstraints.maxHeight.isFinite
        ? math.min(inputConstraints.maxHeight, clampedAvailableHeight)
        : clampedAvailableHeight;
    final maxHeight = allowedMaxHeight.clamp(0.0, viewportSize.height);
    final minHeight = math.min(inputConstraints.minHeight, maxHeight).clamp(0.0, maxHeight);

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
    final maxDx = math.max(0.0, screenSize.width - contentWidth);
    final maxDy = math.max(0.0, screenSize.height - contentHeight);
    dx = dx.clamp(0.0, maxDx);
    dy = dy.clamp(0.0, maxDy);

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(PopupPositionDelegate oldDelegate) {
    return oldDelegate.constraints != constraints || oldDelegate.alignment != alignment || oldDelegate.offset != offset;
  }
}
