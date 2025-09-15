import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/app_colors.dart';
import 'package:te_widgets/configs/widget-theme/widget_theme_extension.dart';

ThemeData getTLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    textTheme: getTTextTheme(),
    primarySwatch: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.shade50,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.shade50,
      onSecondaryContainer: AppColors.secondary,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.danger.shade50,
      onErrorContainer: AppColors.danger,
      surface: Colors.white,
      surfaceDim: AppColors.grey.shade50,
      surfaceContainerLowest: AppColors.grey.shade300,
      surfaceContainerLow: AppColors.grey.shade200,
      surfaceContainer: AppColors.grey.shade100.withAlpha(200),
      surfaceContainerHigh: AppColors.grey.shade100.withAlpha(150),
      onSurface: AppColors.grey[950]!,
      onSurfaceVariant: AppColors.grey.shade800,
      outline: AppColors.grey.shade300,
      outlineVariant: AppColors.grey.shade100,
      shadow: AppColors.grey.shade200.withAlpha(100),
      scrim: AppColors.grey.shade900.withAlpha(150),
    ),
  ).copyWith(extensions: [
    TWidgetThemeExtension().copyWith(
      layoutFrame: AppColors.grey.shade800,
    )
  ]);
}

ThemeData getTDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    textTheme: getTTextTheme(),
    primarySwatch: AppColors.primary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.shade700,
      onPrimaryContainer: AppColors.primary.shade200,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.shade700,
      onSecondaryContainer: AppColors.secondary.shade200,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.danger.shade700,
      onErrorContainer: AppColors.danger.shade200,
      surface: AppColors.grey[950]!,
      surfaceDim: AppColors.grey.shade900,
      surfaceContainerLowest: AppColors.grey.shade700,
      surfaceContainerLow: AppColors.grey.shade800,
      surfaceContainer: AppColors.grey.shade800.withAlpha(200),
      surfaceContainerHigh: AppColors.grey.shade900.withAlpha(150),
      onSurface: AppColors.grey.shade300,
      onSurfaceVariant: AppColors.grey.shade400,
      outline: AppColors.grey.shade800,
      outlineVariant: AppColors.grey.shade900,
      shadow: AppColors.grey.shade900.withAlpha(125),
      scrim: AppColors.grey.shade900.withAlpha(150),
    ),
  ).copyWith(extensions: [
    TWidgetThemeExtension().copyWith(
      layoutFrame: AppColors.grey.shade900,
    )
  ]);
}

TextTheme getTTextTheme() {
  TextStyle textStyle(double size, FontWeight weight) {
    return TextStyle(
      fontFamily: 'Lexend',
      package: 'te_widgets',
      color: AppColors.grey.shade600,
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
