import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

enum TVariant {
  solid,
  tonal,
  outline,
  softOutline,
  filledOutline,
  text,
  softText,
  filledText;

  FontWeight get fontWeight {
    return switch (this) {
      solid || tonal || text || softText || filledText => FontWeight.w400,
      outline || softOutline || filledOutline => FontWeight.w300,
    };
  }
}

@immutable
class TWidgetTheme {
  final bool isDarkMode;
  final TVariant type;
  final MaterialColor color;
  final Color container;
  final Color containerVariant;
  final Color onContainer;
  final Color onContainerVariant;
  final Color? outline;
  final Color? outlineVariant;
  final Color? shadow;

  const TWidgetTheme({
    required this.isDarkMode,
    required this.type,
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

  TWidgetTheme copyWith({
    bool? isDarkMode,
    TVariant? type,
    MaterialColor? color,
    Color? container,
    Color? containerVariant,
    Color? onContainer,
    Color? onContainerVariant,
    Color? outline,
    Color? outlineVariant,
    Color? shadow,
  }) {
    return TWidgetTheme(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      type: type ?? this.type,
      color: color ?? this.color,
      container: container ?? this.container,
      containerVariant: containerVariant ?? this.containerVariant,
      onContainer: onContainer ?? this.onContainer,
      onContainerVariant: onContainerVariant ?? this.onContainerVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      shadow: shadow ?? this.shadow,
    );
  }

  TWidgetTheme rebuild({bool? isDarkMode, Color? color, TVariant? type}) {
    return TWidgetTheme.from(
      isDarkMode ?? this.isDarkMode,
      color ?? this.color,
      type ?? this.type,
    );
  }

  static TWidgetTheme surfaceTheme(ColorScheme colors, {TVariant variant = TVariant.tonal, bool active = false}) {
    return TWidgetTheme(
      isDarkMode: colors.isDarkMode,
      type: variant,
      color: active ? AppColors.primary : AppColors.grey,
      container: active ? colors.primaryContainer : colors.surfaceContainer,
      containerVariant: active ? colors.primaryContainer : colors.surfaceContainerLow,
      onContainer: active ? colors.onPrimaryContainer : colors.onSurface,
      onContainerVariant: active ? colors.onPrimaryContainer : colors.onSurfaceVariant,
      shadow: colors.shadow,
    );
  }

  static TWidgetTheme solidTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.solid,
      color: m,
      container: m.shade(400),
      containerVariant: m.shade(400).withAlpha(200),
      onContainer: m.shade(50),
      onContainerVariant: m.shade(50),
      shadow: m.shade(900).withAlpha(35),
    );
  }

  static TWidgetTheme tonalTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.tonal,
      color: m,
      container: isDarkMode ? m.shade(800).withAlpha(200) : m.shade(50),
      containerVariant: isDarkMode ? m.shade(800) : m.shade(100),
      onContainer: isDarkMode ? m.shade(100) : m.shade(400),
      onContainerVariant: isDarkMode ? m.shade(200) : m.shade(500),
      shadow: m.shade(600).withAlpha(35),
    );
  }

  static TWidgetTheme outlineTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.outline,
      color: m,
      container: Colors.transparent,
      containerVariant: Colors.transparent,
      onContainer: m.shade(400),
      onContainerVariant: isDarkMode ? m.shade(300) : m.shade(500),
      outline: m.shade(300),
      outlineVariant: m.shade(400),
      shadow: m.shade(400).withAlpha(35),
    );
  }

  static TWidgetTheme softOutlineTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.softOutline,
      color: m,
      container: Colors.transparent,
      containerVariant: isDarkMode ? m.shade(800).withAlpha(200) : m.shade(50),
      onContainer: m.shade(400),
      onContainerVariant: isDarkMode ? m.shade(100) : m.shade(400),
      outline: m.shade(300),
      outlineVariant: isDarkMode ? m.shade(400) : m.shade(200),
      shadow: m.shade(400).withAlpha(35),
    );
  }

  static TWidgetTheme filledOutlineTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.filledOutline,
      color: m,
      container: Colors.transparent,
      containerVariant: m.shade(400),
      onContainer: m.shade(400),
      onContainerVariant: m.shade(50),
      outline: m.shade(300),
      shadow: m.shade(400).withAlpha(35),
    );
  }

  static TWidgetTheme textTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.text,
      color: m,
      container: Colors.transparent,
      containerVariant: Colors.transparent,
      onContainer: m.shade(400),
      onContainerVariant: isDarkMode ? m.shade(300) : m.shade(500),
    );
  }

  static TWidgetTheme softTextTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.softText,
      color: m,
      container: Colors.transparent,
      containerVariant: isDarkMode ? m.shade(800).withAlpha(200) : m.shade(50),
      onContainer: m.shade(400),
      onContainerVariant: isDarkMode ? m.shade(100) : m.shade(400),
    );
  }

  static TWidgetTheme filledTextTheme(Color color, [bool isDarkMode = false]) {
    final m = color.toMaterial();
    return TWidgetTheme(
      isDarkMode: isDarkMode,
      type: TVariant.filledText,
      color: m,
      container: Colors.transparent,
      containerVariant: m.shade(400),
      onContainer: m.shade(400),
      onContainerVariant: m.shade(50),
    );
  }

  static final Map<String, TWidgetTheme> _baseThemeCache = {};

  static String _cacheKey(Color color, TVariant type, bool isDark) {
    return '${color.toARGB32()}_${type.name}_$isDark';
  }

  static TWidgetTheme from(bool isDarkMode, Color color, TVariant type) {
    final key = _cacheKey(color, type, isDarkMode);

    return _baseThemeCache.putIfAbsent(key, () {
      return switch (type) {
        TVariant.solid => solidTheme(color, isDarkMode),
        TVariant.tonal => tonalTheme(color, isDarkMode),
        TVariant.outline => outlineTheme(color, isDarkMode),
        TVariant.softOutline => softOutlineTheme(color, isDarkMode),
        TVariant.filledOutline => filledOutlineTheme(color, isDarkMode),
        TVariant.text => textTheme(color, isDarkMode),
        TVariant.softText => softTextTheme(color, isDarkMode),
        TVariant.filledText => filledTextTheme(color, isDarkMode),
      };
    });
  }

  static void clearCache() {
    _baseThemeCache.clear();
  }
}
