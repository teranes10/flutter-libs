import 'package:flutter/material.dart';
import 'package:te_widgets/configs/widget-theme/widget_theme_extension.dart';
import 'package:te_widgets/configs/widget-theme/widget_theme.dart';

extension ColorSchemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TWidgetThemeExtension get theme => Theme.of(this).extension<TWidgetThemeExtension>() ?? TWidgetThemeExtension();
  TWidgetTheme getWidgetTheme(TVariant type, Color color) => TThemeResolver.getWidgetTheme(this, color, type);
}

extension ColorExtensions on Color {
  Color shade(int shade) {
    if (this is MaterialColor) return (this as MaterialColor)[shade]!;

    switch (shade) {
      case 50:
        return Color.lerp(this, Colors.white, 0.9)!;
      case 100:
        return Color.lerp(this, Colors.white, 0.8)!;
      case 200:
        return Color.lerp(this, Colors.white, 0.6)!;
      case 300:
        return Color.lerp(this, Colors.white, 0.4)!;
      case 400:
        return Color.lerp(this, Colors.white, 0.2)!;
      case 500:
        return this; // Original color
      case 600:
        return Color.lerp(this, Colors.black, 0.1)!;
      case 700:
        return Color.lerp(this, Colors.black, 0.2)!;
      case 800:
        return Color.lerp(this, Colors.black, 0.3)!;
      case 900:
        return Color.lerp(this, Colors.black, 0.4)!;
      default:
        return this; // Return original if invalid shade
    }
  }

  bool get isTransparent {
    return a == 0;
  }

  Color o(double opacity) {
    if (a == 0) return this;
    return withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
  }
}

class ColorHelper {
  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }
}

class StateHelper {
  static WidgetStateProperty<T> resolveState<T>(T normal, {T? active, T? disabled}) {
    return WidgetStateProperty.resolveWith((states) {
      if (disabled != null && states.contains(WidgetState.disabled)) return disabled;
      if (active != null &&
          (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed) || states.contains(WidgetState.selected))) {
        return active;
      }
      return normal;
    });
  }
}
