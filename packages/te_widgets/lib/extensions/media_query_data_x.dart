import 'package:flutter/material.dart';
import 'package:te_widgets/widgets/grid/grid.dart';

extension MediaQueryDataX on MediaQueryData {
  double get screenWidth => size.width;
  double get screenHeight => size.height;

  bool get isMobile => screenWidth < kMobileBreakpoint;
  bool get isTablet => screenWidth >= kMobileBreakpoint && screenWidth < kDesktopBreakpoint;
  bool get isDesktop => screenWidth >= kDesktopBreakpoint;

  TextScaler scaleText({double? sm, double? md, double? lg}) {
    final current = textScaler;

    if (isMobile && sm != null) {
      return current.clamp(minScaleFactor: sm, maxScaleFactor: sm);
    } else if (isTablet && md != null) {
      return current.clamp(minScaleFactor: md, maxScaleFactor: md);
    } else if (isDesktop && lg != null) {
      return current.clamp(minScaleFactor: lg, maxScaleFactor: lg);
    }

    return current;
  }
}
