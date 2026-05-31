import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

@immutable
class TAppTheme {
  final ColorScheme lightScheme;
  final ColorScheme darkScheme;
  final TWidgetThemeExtension Function(ColorScheme scheme) widgetThemeBuilder;

  const TAppTheme({
    required this.lightScheme,
    required this.darkScheme,
    required this.widgetThemeBuilder,
  });

  factory TAppTheme.defaultTheme({
    MaterialColor primary = AppColors.primary,
    MaterialColor secondary = AppColors.secondary,
    MaterialColor danger = AppColors.danger,
    MaterialColor grey = AppColors.grey,
  }) {
    return TAppTheme(
      lightScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primary.shade50,
        onPrimaryContainer: primary,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondary.shade50,
        onSecondaryContainer: secondary,
        error: danger,
        onError: Colors.white,
        errorContainer: danger.shade50,
        onErrorContainer: danger,
        surfaceBright: Colors.white,
        surface: Colors.white,
        surfaceDim: grey.shade300.withValues(alpha: 0.25),
        surfaceContainerLowest: grey.shade100.o(0.3),
        surfaceContainerLow: grey.shade100.o(0.5),
        surfaceContainer: grey.shade100.o(0.7),
        surfaceContainerHigh: grey.shade100.o(0.85),
        surfaceContainerHighest: grey.shade100,
        onSurface: grey.shade900,
        onSurfaceVariant: grey.shade800,
        outline: grey.shade300,
        outlineVariant: grey.shade100,
        shadow: grey.shade200.withAlpha(100),
        scrim: grey.shade900.withAlpha(150),
      ),
      darkScheme: ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primary.shade700,
        onPrimaryContainer: primary.shade200,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondary.shade700,
        onSecondaryContainer: secondary.shade200,
        error: danger,
        onError: Colors.white,
        errorContainer: danger.shade700.o(0.6),
        onErrorContainer: danger.shade100,
        surfaceBright: grey[950]!,
        surface: grey[950]!,
        surfaceDim: grey.shade500.withValues(alpha: 0.35),
        surfaceContainerLowest: grey.shade900.o(0.15),
        surfaceContainerLow: grey.shade900.o(0.3),
        surfaceContainer: grey.shade900.o(0.5),
        surfaceContainerHigh: grey.shade900.o(0.75),
        surfaceContainerHighest: grey.shade900,
        onSurface: grey.shade300,
        onSurfaceVariant: grey.shade400,
        outline: grey.shade800,
        outlineVariant: grey.shade900,
        shadow: grey.shade900.withAlpha(100),
        scrim: grey.shade900.withAlpha(150),
      ),
      widgetThemeBuilder: (scheme) => TWidgetThemeExtension.defaultTheme(scheme),
    );
  }

  TAppTheme copyWith({
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
    TWidgetThemeExtension Function(ColorScheme)? widgetThemeBuilder,
  }) {
    return TAppTheme(
      lightScheme: lightScheme ?? this.lightScheme,
      darkScheme: darkScheme ?? this.darkScheme,
      widgetThemeBuilder: widgetThemeBuilder ?? this.widgetThemeBuilder,
    );
  }

  ThemeData get lightTheme {
    final widgetTheme = widgetThemeBuilder(lightScheme);

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: lightScheme,
      primarySwatch: widgetTheme.primary,
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Lexend', package: 'te_widgets'),
      extensions: [widgetTheme],
    );
  }

  ThemeData get darkTheme {
    final widgetTheme = widgetThemeBuilder(darkScheme);

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      primarySwatch: widgetTheme.primary,
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Lexend', package: 'te_widgets'),
      extensions: [widgetTheme],
    );
  }
}
