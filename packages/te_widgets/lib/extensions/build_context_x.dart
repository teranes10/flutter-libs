import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:flutter/foundation.dart';

bool get kIsMobilePlatform {
  final p = defaultTargetPlatform;
  return p == TargetPlatform.android || p == TargetPlatform.iOS;
}

bool get kIsDesktopPlatform {
  final p = defaultTargetPlatform;
  return p == TargetPlatform.macOS || p == TargetPlatform.windows || p == TargetPlatform.linux;
}

extension BuildContextX on BuildContext {
  /// State of the innermost matched route. Unlike `GoRouterState.of`, which inside a `ShellRoute`
  /// returns the shell's own state, this carries the leaf route's metadata. Still rebuilds on navigation.
  GoRouterState get leafRouteState {
    GoRouterState.of(this);
    return GoRouter.of(this).state;
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  TWidgetThemeExtension get theme {
    final ext = Theme.of(this).extension<TWidgetThemeExtension>();
    return ext ?? TWidgetThemeExtension.defaultTheme(colors);
  }

  TWidgetThemeExtension? get themeOrNull => Theme.of(this).extension<TWidgetThemeExtension>();

  TWidgetTheme getWidgetTheme(TVariant type, [Color? color]) =>
      color != null ? TWidgetTheme.from(isDarkMode, color, type) : TWidgetTheme.surfaceTheme(colors, variant: type);

  Color getBackgroundColor([Color? defaultColor]) => TBackgroundColorScope.maybeOf(this) ?? defaultColor ?? colors.surface;

  ({Color tonal, Color bg}) getTonalBackground([Color? color, Color? defaultBgColor]) {
    final bg = getBackgroundColor(defaultBgColor);
    if (color != null && bg != color) return (tonal: color, bg: bg);
    return (tonal: (color ?? bg).adaptiveContrast(this, 0.025), bg: bg);
  }

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.screenWidth;
  double get screenHeight => mediaQuery.screenHeight;
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  bool get isMobile => mediaQuery.isMobile;
  bool get isTablet => mediaQuery.isTablet;
  bool get isDesktop => mediaQuery.isDesktop;

  bool get isMobilePlatform {
    final p = Theme.of(this).platform;
    return p == TargetPlatform.android || p == TargetPlatform.iOS;
  }

  bool get isDesktopPlatform {
    final p = Theme.of(this).platform;
    return p == TargetPlatform.macOS || p == TargetPlatform.windows || p == TargetPlatform.linux;
  }

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
