import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_button.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/configs/theme/theme_text.dart';

ThemeData teWidgetsTheme(BuildContext context) {
  return ThemeData(
    // Color Scheme
    colorScheme: getColorScheme(),
    primarySwatch: AppColors.primary,

    // Text Theme
    textTheme: getTextTheme(),

    // Button Theme
    elevatedButtonTheme: getElevatedButtonTheme(),
  );
}
