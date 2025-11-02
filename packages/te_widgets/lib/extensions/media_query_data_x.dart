import 'package:flutter/material.dart';

extension MediaQueryDataX on MediaQueryData {
  double get screenWidth => size.width;
  double get screenHeight => size.height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

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
