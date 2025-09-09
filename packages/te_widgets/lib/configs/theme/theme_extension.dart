import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_color_scheme.dart';
import 'package:te_widgets/configs/theme/theme_widget_color_scheme.dart';

extension ColorSchemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get theme => Theme.of(this).colorScheme;
  TColorScheme get exTheme => Theme.of(this).extension<TColorScheme>() ?? TColorScheme();
  TWidgetColorScheme getWidgetTheme(TColorType type, Color color) => TWidgetColorScheme.from(this, color, type);
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
