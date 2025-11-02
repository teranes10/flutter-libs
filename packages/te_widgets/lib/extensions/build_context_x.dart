import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

extension BuildContextX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colors => Theme.of(this).colorScheme;

  TWidgetThemeExtension get theme {
    final ext = Theme.of(this).extension<TWidgetThemeExtension>();
    if (ext == null) {
      throw FlutterError(
        'TWidgetThemeExtension is not found in ThemeData. '
        'Ensure you have added it to your ThemeData.extensions list.',
      );
    }
    return ext;
  }

  TWidgetTheme getWidgetTheme(TVariant type, Color? color) => TThemeResolver.getWidgetTheme(this, color ?? theme.primary, type);

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.screenWidth;
  double get screenHeight => mediaQuery.screenHeight;

  bool get isMobile => mediaQuery.isMobile;
  bool get isTablet => mediaQuery.isTablet;
  bool get isDesktop => mediaQuery.isDesktop;
}
