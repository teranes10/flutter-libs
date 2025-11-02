import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TVariant { solid, tonal, outline, softOutline, filledOutline, text, softText, filledText }

@immutable
class TWidgetTheme {
  final MaterialColor color;
  final Color container;
  final Color containerVariant;
  final Color onContainer;
  final Color onContainerVariant;
  final Color? outline;
  final Color? outlineVariant;
  final Color? shadow;

  const TWidgetTheme({
    required this.color,
    required this.container,
    required this.containerVariant,
    required this.onContainer,
    required this.onContainerVariant,
    this.outline,
    this.outlineVariant,
    this.shadow,
  });

  BoxBorder? get boxBorder => outline != null ? Border.all(color: outline!) : null;

  List<BoxShadow>? get boxShadow => shadow != null ? [BoxShadow(color: shadow!, blurRadius: 12, spreadRadius: 2)] : null;

  WidgetStateProperty<Color?> get backgroundState => WidgetStatePropertyHelper.resolveState(container,
      active: containerVariant, disabled: container.isTransparent ? container.o(0.4) : container);

  WidgetStateProperty<Color?> get foregroundState =>
      WidgetStatePropertyHelper.resolveState(onContainer, active: onContainerVariant, disabled: onContainer.o(0.5));

  WidgetStateProperty<BorderSide?> get borderSideState => WidgetStatePropertyHelper.resolveState(
        outline != null ? BorderSide(color: outline!) : BorderSide.none,
        active: outlineVariant != null ? BorderSide(color: outlineVariant!) : BorderSide.none,
        disabled: outline != null ? BorderSide(color: outline!.o(0.4)) : BorderSide.none,
      );

  factory TWidgetTheme.from(BuildContext context, Color color, TVariant type) {
    final isDarkMode = context.isDarkMode;
    MaterialColor mColor = color.toMaterial();
    Color shade(int value) => mColor.shade(value);
    Color alpha(Color color, int a) => color.withAlpha(a);

    return switch (type) {
      TVariant.solid => TWidgetTheme(
          color: mColor,
          container: isDarkMode ? shade(500) : shade(400),
          containerVariant: alpha(shade(400), 200),
          onContainer: shade(50),
          onContainerVariant: shade(50),
          shadow: alpha(shade(900), 35),
        ),
      TVariant.tonal => TWidgetTheme(
          color: mColor,
          container: isDarkMode ? shade(900) : shade(50),
          containerVariant: isDarkMode ? shade(800) : shade(100),
          onContainer: isDarkMode ? shade(100) : shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
          shadow: alpha(shade(600), 35),
        ),
      TVariant.outline => TWidgetTheme(
          color: mColor,
          container: Colors.transparent,
          containerVariant: Colors.transparent,
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
          outline: shade(300),
          outlineVariant: shade(400),
          shadow: alpha(shade(400), 35),
        ),
      TVariant.softOutline => TWidgetTheme(
          color: mColor,
          container: Colors.transparent,
          containerVariant: isDarkMode ? shade(700) : shade(50),
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(200) : shade(500),
          outline: shade(300),
          outlineVariant: isDarkMode ? shade(400) : shade(200),
          shadow: alpha(shade(400), 35),
        ),
      TVariant.filledOutline => TWidgetTheme(
          color: mColor,
          container: Colors.transparent,
          containerVariant: shade(400),
          onContainer: shade(400),
          onContainerVariant: shade(50),
          outline: shade(300),
          shadow: alpha(shade(400), 35),
        ),
      TVariant.text => TWidgetTheme(
          color: mColor,
          container: Colors.transparent,
          containerVariant: Colors.transparent,
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
        ),
      TVariant.softText => TWidgetTheme(
          color: mColor,
          container: Colors.transparent,
          containerVariant: isDarkMode ? shade(700) : shade(50),
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
        ),
      TVariant.filledText => TWidgetTheme(
          color: mColor,
          container: Colors.transparent,
          containerVariant: shade(400),
          onContainer: shade(400),
          onContainerVariant: shade(50),
        )
    };
  }
}

class TThemeResolver {
  static final Map<String, TWidgetTheme> _baseThemeCache = {};

  static String _cacheKey(Color color, TVariant variant, bool isDark) {
    return '${color.toARGB32()}_${variant.name}_$isDark';
  }

  static TWidgetTheme getWidgetTheme(BuildContext context, Color color, TVariant variant) {
    final key = _cacheKey(color, variant, context.isDarkMode);
    return _baseThemeCache.putIfAbsent(key, () => TWidgetTheme.from(context, color, variant));
  }

  static void clearCache() {
    _baseThemeCache.clear();
  }
}
