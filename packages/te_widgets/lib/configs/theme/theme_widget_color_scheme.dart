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

  factory TWidgetColorScheme.from(BuildContext context, MaterialColor c, TColorType type) {
    final isDarkMode = context.isDarkMode;
    final theme = context.theme;

    switch (type) {
      case TColorType.solid:
        return TWidgetColorScheme(
            container: c.shade400,
            containerVariant: c.shade400.withValues(alpha: 35),
            onContainer: c.shade50,
            onContainerVariant: c.shade50,
            shadow: c.shade900.withAlpha(35));
      case TColorType.tonal:
        return TWidgetColorScheme(
            container: isDarkMode ? c.shade700 : c.shade50,
            containerVariant: isDarkMode ? c.shade800 : c.shade100,
            onContainer: isDarkMode ? c.shade100 : c.shade400,
            onContainerVariant: isDarkMode ? c.shade300 : c.shade500,
            shadow: c.shade600.withAlpha(35));
      case TColorType.outline:
        return TWidgetColorScheme(
            container: theme.surface,
            containerVariant: theme.surface,
            onContainer: c.shade400,
            onContainerVariant: isDarkMode ? c.shade300 : c.shade500,
            outline: c.shade300,
            outlineVariant: c.shade400,
            shadow: c.shade400.withAlpha(35));
      case TColorType.softOutline:
        return TWidgetColorScheme(
            container: theme.surface,
            containerVariant: isDarkMode ? c.shade700 : c.shade50,
            onContainer: c.shade400,
            onContainerVariant: isDarkMode ? c.shade200 : c.shade500,
            outline: c.shade300,
            outlineVariant: isDarkMode ? c.shade400 : c.shade200,
            shadow: c.shade400.withAlpha(35));
      case TColorType.filledOutline:
        return TWidgetColorScheme(
            container: theme.surface,
            containerVariant: c.shade400,
            onContainer: c.shade400,
            onContainerVariant: c.shade50,
            outline: c.shade300,
            shadow: c.shade400.withAlpha(35));
      case TColorType.text:
        return TWidgetColorScheme(
          container: Colors.transparent,
          containerVariant: Colors.transparent,
          onContainer: c.shade400,
          onContainerVariant: isDarkMode ? c.shade300 : c.shade500,
        );
      case TColorType.softText:
        return TWidgetColorScheme(
          container: Colors.transparent,
          containerVariant: isDarkMode ? c.shade700 : c.shade50,
          onContainer: c.shade400,
          onContainerVariant: isDarkMode ? c.shade300 : c.shade500,
        );
      case TColorType.filledText:
        return TWidgetColorScheme(
          container: Colors.transparent,
          containerVariant: c.shade400,
          onContainer: c.shade400,
          onContainerVariant: c.shade50,
        );
    }
  }
}
