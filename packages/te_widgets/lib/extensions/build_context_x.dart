import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';

extension BuildContextX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

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

  TWidgetTheme getWidgetTheme(TVariant type, Color? color) => TWidgetTheme.from(isDarkMode, color ?? theme.primary, type);

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.screenWidth;
  double get screenHeight => mediaQuery.screenHeight;
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  bool get isMobile => mediaQuery.isMobile;
  bool get isTablet => mediaQuery.isTablet;
  bool get isDesktop => mediaQuery.isDesktop;

  /// Navigates to a path with optional breadcrumb labels for dynamic segments.
  ///
  /// The [labels] map is used by [TBreadcrumbs] to display friendly names
  /// instead of IDs or slugs in the breadcrumb path.
  ///
  /// Example:
  /// ```dart
  /// context.tGo(
  ///   '/categories/clothes/t-shirt',
  ///   labels: {
  ///     'clothes': 'Fashion',
  ///     't-shirt': 'Premium Tees'
  ///   }
  /// );
  /// ```
  void tGo(String location, {Map<String, String>? labels, Map<String, Object>? extra, bool push = false}) {
    Map<String, Object> finalExtra = extra ?? <String, Object>{};

    if (labels != null) {
      if (finalExtra.containsKey('labels')) {
        throw Exception("The 'labels' key in extra is reserved for tGo().");
      }

      finalExtra['labels'] = labels;
    }

    push ? this.push(location, extra: finalExtra) : go(location, extra: finalExtra);
  }
}
