import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/configs/theme/theme_text.dart';

ThemeData teWidgetsTheme({MaterialColor? primary, MaterialColor? secondary}) {
  return ThemeData(
    colorScheme: getColorScheme(primary: primary, secondary: secondary),
    primarySwatch: AppColors.primary,
    textTheme: getTextTheme(),
  );
}
