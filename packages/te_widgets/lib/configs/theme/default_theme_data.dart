import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

@immutable
class TAppTheme {
  final ColorScheme lightScheme;
  final ColorScheme darkScheme;
  final TWidgetThemeExtension Function(ColorScheme colors) widgetThemeBuilder;

  /// Scaffold background overrides (default: [AppColors.lightBackground] / [AppColors.darkBackground]).
  final Color? lightBackground;
  final Color? darkBackground;

  const TAppTheme({
    this.lightBackground,
    this.darkBackground,
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
        surfaceContainerHighest: grey.shade200.lighten(0.15),
        onSurface: grey.shade900,
        onSurfaceVariant: grey.shade800,
        outline: grey.shade500,
        outlineVariant: grey.shade300,
        shadow: grey[950],
        scrim: grey[950]?.withAlpha(75),
        surfaceTint: grey.shade50.o(0.1),
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
        outline: grey.shade600,
        outlineVariant: grey.shade700,
        shadow: Colors.black,
        scrim: Colors.black26,
        surfaceTint: grey[950]!.lighten(0.12).o(0.1),
      ),
      widgetThemeBuilder: (scheme) => TWidgetThemeExtension.defaultTheme(scheme),
    );
  }

  factory TAppTheme.defaultTheme2({
    MaterialColor primary = AppColors.primary,
    MaterialColor secondary = AppColors.secondary,
    MaterialColor danger = AppColors.danger,
    MaterialColor grey = AppColors.grey,
  }) {
    return TAppTheme(
      lightScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        error: danger,
        onError: Colors.white,
        errorContainer: danger.shade50,
        onErrorContainer: danger,
        surface: AppColors.lightSurface,
        onSurface: const Color(0xFF172033),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF7F8FC),
        surfaceContainer: const Color(0xFFF0F2F7),
        surfaceContainerHigh: const Color(0xFFE9ECF3),
        outline: const Color(0xFFAAB3C2),
        outlineVariant: const Color(0xFFE1E5ED),
      ),
      darkScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary.shade300,
        secondary: secondary.shade300,
        error: danger,
        onError: Colors.white,
        errorContainer: danger.shade800.lighten(0.03),
        onErrorContainer: danger.shade100,
        surface: AppColors.darkSurface,
        onSurface: const Color(0xFFF1F4FA),
        surfaceContainerLowest: const Color(0xFF0D1017),
        surfaceContainerLow: const Color(0xFF171B25),
        surfaceContainer: const Color(0xFF1D2330),
        surfaceContainerHigh: const Color(0xFF252C3A),
        outline: const Color(0xFF687386),
        outlineVariant: const Color(0xFF303746),
      ),
      widgetThemeBuilder: (scheme) => TWidgetThemeExtension.defaultTheme(scheme),
    );
  }

  TAppTheme copyWith({
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
    TWidgetThemeExtension Function(ColorScheme colors)? widgetThemeBuilder,
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
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightBackground ?? AppColors.lightBackground,
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Lexend', package: 'te_widgets'),
      scrollbarTheme: scrollbarTheme(lightScheme),
      extensions: [widgetTheme],
    );
  }

  ThemeData get darkTheme {
    final widgetTheme = widgetThemeBuilder(darkScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkBackground ?? AppColors.darkBackground,
      primarySwatch: widgetTheme.primary,
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Lexend', package: 'te_widgets'),
      scrollbarTheme: scrollbarTheme(darkScheme),
      extensions: [widgetTheme],
    );
  }

  ScrollbarThemeData scrollbarTheme(ColorScheme colors) {
    return ScrollbarThemeData(
      interactive: true,
      thumbVisibility: WidgetStateProperty.resolveWith<bool>((states) => states.contains(WidgetState.hovered)),
      trackVisibility: const WidgetStatePropertyAll(false),
      radius: const Radius.circular(12.0),
      crossAxisMargin: -2,
      thickness: WidgetStateProperty.resolveWith<double?>((states) => states.contains(WidgetState.hovered) ? 6.0 : 5.0),
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.hovered) ? colors.outlineVariant : colors.outline,
      ),
    );
  }
}
