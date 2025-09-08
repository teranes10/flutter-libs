import 'package:flutter/material.dart';
import 'package:te_widgets/configs/theme/theme_extension.dart';

enum TColorType { solid, tonal, outline, softOutline, filledOutline, text, softText, filledText }

class TWidgetColorScheme {
  final Color container;
  final Color containerVariant;
  final Color onContainer;
  final Color onContainerVariant;
  final Color? outline;
  final Color? outlineVariant;
  final Color? shadow;
  final bool activeState;

  TWidgetColorScheme({
    required this.container,
    required this.containerVariant,
    required this.onContainer,
    required this.onContainerVariant,
    this.outline,
    this.outlineVariant,
    this.shadow,
    this.activeState = false,
  });

  BoxBorder? get boxBorder => outline != null ? Border.all(color: outline!) : null;
  List<BoxShadow>? get boxShadow => shadow != null ? [BoxShadow(color: shadow!, blurRadius: 12, spreadRadius: 2)] : null;

  WidgetStateProperty<T> _resolveState<T>(T normal, T active, T disabled) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return disabled;
      if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered) || activeState) return active;
      return normal;
    });
  }

  WidgetStateProperty<Color?> get backgroundState => _resolveState(container, containerVariant, container.withAlpha(100));
  WidgetStateProperty<Color?> get foregroundState => _resolveState(onContainer, onContainerVariant, onContainer.withAlpha(100));
  WidgetStateProperty<BorderSide?> get borderSideState => _resolveState(
      outline != null ? BorderSide(color: outline!) : BorderSide.none,
      outlineVariant != null ? BorderSide(color: outlineVariant!) : BorderSide.none,
      outline != null ? BorderSide(color: outline!) : BorderSide.none);

  factory TWidgetColorScheme.from(BuildContext context, Color c, TColorType type) {
    final isDarkMode = context.isDarkMode;
    final theme = context.theme;

    Color shade(int value) => c.shade(value);
    Color alpha(Color color, int a) => color.withAlpha(a);

    switch (type) {
      case TColorType.solid:
        return TWidgetColorScheme(
          container: shade(400),
          containerVariant: alpha(shade(400), 200),
          onContainer: shade(50),
          onContainerVariant: shade(50),
          shadow: alpha(shade(900), 35),
        );
      case TColorType.tonal:
        return TWidgetColorScheme(
          container: isDarkMode ? shade(700) : shade(50),
          containerVariant: isDarkMode ? shade(800) : shade(100),
          onContainer: isDarkMode ? shade(100) : shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
          shadow: alpha(shade(600), 35),
        );
      case TColorType.outline:
        return TWidgetColorScheme(
          container: theme.surface,
          containerVariant: theme.surface,
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
          outline: shade(300),
          outlineVariant: shade(400),
          shadow: alpha(shade(400), 35),
        );
      case TColorType.softOutline:
        return TWidgetColorScheme(
          container: theme.surface,
          containerVariant: isDarkMode ? shade(700) : shade(50),
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(200) : shade(500),
          outline: shade(300),
          outlineVariant: isDarkMode ? shade(400) : shade(200),
          shadow: alpha(shade(400), 35),
        );
      case TColorType.filledOutline:
        return TWidgetColorScheme(
          container: theme.surface,
          containerVariant: shade(400),
          onContainer: shade(400),
          onContainerVariant: shade(50),
          outline: shade(300),
          shadow: alpha(shade(400), 35),
        );
      case TColorType.text:
        return TWidgetColorScheme(
          container: Colors.transparent,
          containerVariant: Colors.transparent,
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
        );
      case TColorType.softText:
        return TWidgetColorScheme(
          container: Colors.transparent,
          containerVariant: isDarkMode ? shade(700) : shade(50),
          onContainer: shade(400),
          onContainerVariant: isDarkMode ? shade(300) : shade(500),
        );
      case TColorType.filledText:
        return TWidgetColorScheme(
          container: Colors.transparent,
          containerVariant: shade(400),
          onContainer: shade(400),
          onContainerVariant: shade(50),
        );
    }
  }
}
