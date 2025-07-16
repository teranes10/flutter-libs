import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_colors.dart';
import 'package:te_widgets/configs/theme/theme_color_scheme.dart';
import 'package:te_widgets/configs/theme/theme_text.dart';

ThemeData getTLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    textTheme: getTTextTheme(),
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
      scrim: AppColors.grey[950]!.withAlpha(25),
    ),
  ).copyWith(extensions: [TColorScheme()]);
}

ThemeData getTDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    textTheme: getTTextTheme(),
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
      shadow: AppColors.grey.shade900.withAlpha(100),
      scrim: AppColors.grey.shade900.withAlpha(25),
    ),
  ).copyWith(extensions: [TColorScheme()]);
}
