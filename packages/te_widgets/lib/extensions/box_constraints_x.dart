import 'package:flutter/material.dart';

extension BoxConstraintsX on BoxConstraints {
  bool get isMobile => maxWidth < 600;
  bool get isTablet => maxWidth >= 600 && maxWidth < 1024;
  bool get isDesktop => maxWidth >= 1024;
}
