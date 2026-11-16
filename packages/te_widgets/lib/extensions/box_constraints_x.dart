import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/grid/grid.dart';

extension BoxConstraintsX on BoxConstraints {
  bool get isMobile => maxWidth < kMobileBreakpoint;
  bool get isTablet => maxWidth >= kMobileBreakpoint && maxWidth < kDesktopBreakpoint;
  bool get isDesktop => maxWidth >= kDesktopBreakpoint;

  /// Desktop at or above [kLargeDesktopBreakpoint]; also true for [isDesktop].
  bool get isLargeDesktop => maxWidth >= kLargeDesktopBreakpoint;

  double? get resolvedWidth {
    final maxW = maxWidth;
    final minW = minWidth;

    if (hasTightWidth) return maxWidth;

    if (maxW != double.infinity) {
      return maxW;
    }

    if (minW != double.infinity) {
      return minW;
    }

    return null;
  }
}
