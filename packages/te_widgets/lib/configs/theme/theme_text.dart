import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';

TextTheme getTextTheme() {
  TextStyle textStyle(double size, FontWeight weight) {
    return TextStyle(
      fontFamily: 'Lexend',
      package: 'te_widgets',
      color: AppColors.grey[700],
      fontWeight: weight,
      fontSize: size,
    );
  }

  return TextTheme(
    displayLarge: textStyle(57, FontWeight.w400),
    displayMedium: textStyle(45, FontWeight.w400),
    displaySmall: textStyle(36, FontWeight.w400),
    headlineLarge: textStyle(32, FontWeight.w400),
    headlineMedium: textStyle(28, FontWeight.w400),
    headlineSmall: textStyle(24, FontWeight.w400),
    titleLarge: textStyle(22, FontWeight.w500),
    titleMedium: textStyle(16, FontWeight.w500),
    titleSmall: textStyle(14, FontWeight.w500),
    bodyLarge: textStyle(16, FontWeight.w400),
    bodyMedium: textStyle(14, FontWeight.w400),
    bodySmall: textStyle(12, FontWeight.w400),
    labelLarge: textStyle(14, FontWeight.w500),
    labelMedium: textStyle(12, FontWeight.w500),
    labelSmall: textStyle(11, FontWeight.w500),
  );
}
