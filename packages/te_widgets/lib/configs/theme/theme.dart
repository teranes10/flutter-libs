import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/configs/theme/theme_text.dart';

ThemeData teWidgetsTheme(BuildContext context) {
  return ThemeData(
    colorScheme: getColorScheme(),
    primarySwatch: AppColors.primary,
    textTheme: getTextTheme(),
  );
}
