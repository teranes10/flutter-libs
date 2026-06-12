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
        surfaceDim: grey.shade300.lighten(0.75),
        surfaceContainerLowest: grey.shade100.lighten(0.7),
        surfaceContainerLow: grey.shade100.lighten(0.5),
        surfaceContainer: grey.shade100.lighten(0.3),
        surfaceContainerHigh: grey.shade100.lighten(0.15),
        surfaceContainerHighest: grey.shade100,
        onSurface: grey.shade900,
        onSurfaceVariant: grey.shade800,
        outline: grey.shade300,
        outlineVariant: grey.shade200,
        shadow: grey.shade200.withAlpha(100),
        scrim: grey[950]?.withAlpha(75),
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
        errorContainer: danger.shade800.lighten(0.03),
        onErrorContainer: danger.shade100,
        surfaceBright: grey[950]!,
        surface: grey[950]!,
        surfaceDim: grey[950]!.lighten(0.12),
        surfaceContainerLowest: grey[950]!.lighten(0.025),
        surfaceContainerLow: grey[950]!.lighten(0.05),
        surfaceContainer: grey[950]!.lighten(0.1),
        surfaceContainerHigh: grey[950]!.lighten(0.125),
        surfaceContainerHighest: grey[950]!.lighten(0.15),
        onSurface: grey.shade300,
        onSurfaceVariant: grey.shade400,
        outline: grey.shade800,
        outlineVariant: grey.shade900,
        shadow: grey.shade900.withAlpha(100),
        scrim: Colors.black26,
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
