import 'package:flutter/material.dart';

extension BoxConstraintsX on BoxConstraints {
  bool get isMobile => maxWidth < 600;
  bool get isTablet => maxWidth >= 600 && maxWidth < 1024;
  bool get isDesktop => maxWidth >= 1024;

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
