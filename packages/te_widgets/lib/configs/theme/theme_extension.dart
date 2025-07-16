import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_color_scheme.dart';
import 'package:te_widgets/configs/theme/theme_widget_color_scheme.dart';

extension ColorSchemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get theme => Theme.of(this).colorScheme;
  TColorScheme get exTheme => Theme.of(this).extension<TColorScheme>() ?? TColorScheme();
  TWidgetColorScheme getWidgetTheme(TColorType type, MaterialColor color) => TWidgetColorScheme.from(this, color, type);
}
