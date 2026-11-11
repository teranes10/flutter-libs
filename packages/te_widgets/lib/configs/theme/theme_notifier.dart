import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';

final themeModeKey = 'te_theme_mode';
final sidebarMinifiedKey = 'te_sidebar_minified';
final sidebarModeKey = 'te_sidebar_mode';
final primaryColorIndexKey = 'te_primary_color_index';
final tintByAccentKey = 'te_tint_by_accent';
final customColorKey = 'te_custom_color';
final schemeOverridesKey = 'te_scheme_overrides';
final layoutStyleKey = 'te_layout_style';

ThemeMode _initialTheme = ThemeMode.light;
TSidebarMode _initialSidebarMode = TSidebarMode.full;
int _initialPrimaryColorIndex = 0;
Color? _initialCustomColor;
bool _initialTintByAccent = false;
Map<String, int> _initialLightOverrides = {};
Map<String, int> _initialDarkOverrides = {};
TLayoutStyle _initialLayoutStyle = TLayoutStyle.layout1;

/// Which `TLayout` implementation the app renders.
enum TLayoutStyle {
  /// Sidebar + top bar (profile in the top bar).
  layout1,

  /// Sidebar only (profile pinned in the sidebar).
  layout2;

  String get label => this == layout1 ? 'Layout 1' : 'Layout 2';
}

/// Tristate modes for the navigation sidebar.
enum TSidebarMode {
  minified,
  full,
  none;

  bool get isMinified => this == TSidebarMode.minified;
  bool get isFull => this == TSidebarMode.full;
  bool get isNone => this == TSidebarMode.none;
}

class TThemeState {
  final ThemeMode themeMode;
  final int primaryColorIndex;
  final TLayoutStyle layoutStyle;

  /// User-picked accent; overrides [primaryColorIndex] when set.
  final Color? customColor;

  /// Per-property [ColorScheme] overrides (key = property name, value = ARGB) for each brightness.
  final Map<String, int> lightOverrides;
  final Map<String, int> darkOverrides;

  /// When true, surfaces/outlines are subtly tinted with the accent.
  final bool tintByAccent;

  MaterialColor get primaryColor => customColor != null ? _swatchFrom(customColor!) : primaryColorOptions[primaryColorIndex].color;

  /// Values derived from a custom accent (e.g. a readable `onPrimary`); user overrides win over these.
  Map<String, int> _accentDerived(ColorScheme base) {
    final accent = primaryColor.shade500;
    return {
      if (customColor != null) 'onPrimary': (customColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white).toARGB32(),
      if (tintByAccent) ..._tintedKeys.map((k, t) => MapEntry(k, Color.lerp(schemeColor(base, k), accent, t)!.toARGB32())),
      if (tintByAccent) 'surfaceTint': accent.withValues(alpha: 0.1).toARGB32(),
    };
  }

  /// Scaffold background: user override, else the accent-tinted default when [tintByAccent], else null (default).
  Color? _background(Map<String, int> overrides, Color base) {
    final o = overrides[kScaffoldBackgroundKey];
    if (o != null) return Color(o);
    return tintByAccent ? Color.lerp(base, primaryColor.shade500, 0.02) : null;
  }

  static const _tintedKeys = <String, double>{
    'surfaceDim': 0.04,
    'surfaceContainerLowest': 0.02,
    'surfaceContainerLow': 0.03,
    'surfaceContainer': 0.05,
    'surfaceContainerHigh': 0.06,
    'surfaceContainerHighest': 0.08,
    'outline': 0.12,
    'outlineVariant': 0.12,
    'onSurfaceVariant': 0.1,
  };

  TAppTheme get theme {
    final base = layoutStyle == TLayoutStyle.layout2
        ? TAppTheme.defaultTheme2(primary: primaryColor)
        : TAppTheme.defaultTheme(primary: primaryColor);
    if (lightOverrides.isEmpty && darkOverrides.isEmpty && customColor == null && !tintByAccent) return base;
    return TAppTheme(
      lightScheme: applySchemeOverrides(base.lightScheme, {..._accentDerived(base.lightScheme), ...lightOverrides}),
      darkScheme: applySchemeOverrides(base.darkScheme, {..._accentDerived(base.darkScheme), ...darkOverrides}),
      widgetThemeBuilder: base.widgetThemeBuilder,
      lightBackground: _background(lightOverrides, AppColors.lightBackground),
      darkBackground: _background(darkOverrides, AppColors.darkBackground),
    );
  }

  const TThemeState({
    required this.themeMode,
    required this.primaryColorIndex,
    this.layoutStyle = TLayoutStyle.layout1,
    this.customColor,
    this.tintByAccent = false,
    this.lightOverrides = const {},
    this.darkOverrides = const {},
  });

  TThemeState copyWith({
    ThemeMode? themeMode,
    int? primaryColorIndex,
    TLayoutStyle? layoutStyle,
    Color? customColor,
    bool clearCustomColor = false,
    bool? tintByAccent,
    Map<String, int>? lightOverrides,
    Map<String, int>? darkOverrides,
  }) {
    return TThemeState(
      tintByAccent: tintByAccent ?? this.tintByAccent,
      lightOverrides: lightOverrides ?? this.lightOverrides,
      darkOverrides: darkOverrides ?? this.darkOverrides,
      customColor: clearCustomColor ? null : (customColor ?? this.customColor),
      themeMode: themeMode ?? this.themeMode,
      primaryColorIndex: primaryColorIndex ?? this.primaryColorIndex,
      layoutStyle: layoutStyle ?? this.layoutStyle,
    );
  }
}

Future<void> initializeApp([SharedPreferences? prefs]) async {
  WidgetsFlutterBinding.ensureInitialized();

  final p = prefs ?? await SharedPreferences.getInstance();

  _initialTheme = switch (p.getString(themeModeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.light,
  };

  final savedMode = p.getString(sidebarModeKey);
  if (savedMode != null) {
    _initialSidebarMode = TSidebarMode.values.firstWhere(
      (m) => m.name == savedMode,
      orElse: () => TSidebarMode.full,
    );
  } else {
    final oldMinified = p.getBool(sidebarMinifiedKey) ?? false;
    _initialSidebarMode = oldMinified ? TSidebarMode.minified : TSidebarMode.full;
  }

  _initialPrimaryColorIndex = p.getInt(primaryColorIndexKey) ?? 0;
  _initialTintByAccent = p.getBool(tintByAccentKey) ?? false;
  final customValue = p.getInt(customColorKey);
  _initialCustomColor = customValue == null ? null : Color(customValue);
  Map<String, int> readOverrides(String mode) {
    try {
      final raw = p.getString('${schemeOverridesKey}_$mode');
      if (raw == null) return {};
      return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, v as int));
    } catch (_) {
      return {};
    }
  }

  _initialLightOverrides = readOverrides('light');
  _initialDarkOverrides = readOverrides('dark');
  _initialLayoutStyle = TLayoutStyle.values.firstWhere(
    (l) => l.name == p.getString(layoutStyleKey),
    orElse: () => TLayoutStyle.layout1,
  );
}

class ThemeNotifier extends Notifier<TThemeState> {
  @override
  TThemeState build() {
    return TThemeState(
      themeMode: _initialTheme,
      primaryColorIndex: _initialPrimaryColorIndex,
      customColor: _initialCustomColor,
      tintByAccent: _initialTintByAccent,
      lightOverrides: _initialLightOverrides,
      darkOverrides: _initialDarkOverrides,
      layoutStyle: _initialLayoutStyle,
    );
  }

  void toggleTheme() {
    final nextMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: nextMode);
    _saveThemeMode(nextMode);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveThemeMode(mode);
  }

  /// Overrides that belong to the accent family; dropped when the accent changes so its variants apply.
  static const _accentKeys = ['primary', 'onPrimary', 'primaryContainer', 'onPrimaryContainer'];

  Map<String, int> _withoutAccentKeys(Map<String, int> m) => {...m}..removeWhere((k, _) => _accentKeys.contains(k));

  void selectColor(int index) {
    if (index >= 0 && index < primaryColorOptions.length) {
      state = state.copyWith(
        primaryColorIndex: index,
        clearCustomColor: true,
        lightOverrides: _withoutAccentKeys(state.lightOverrides),
        darkOverrides: _withoutAccentKeys(state.darkOverrides),
      );
      _persistOverrides();
      _savePrimaryColor(index);
      SharedPreferences.getInstance().then((p) => p.remove(customColorKey));
    }
  }

  void setTintByAccent(bool value) {
    state = state.copyWith(tintByAccent: value);
    SharedPreferences.getInstance().then((p) => p.setBool(tintByAccentKey, value));
  }

  void setCustomColor(Color color) {
    state = state.copyWith(
      customColor: color,
      lightOverrides: _withoutAccentKeys(state.lightOverrides),
      darkOverrides: _withoutAccentKeys(state.darkOverrides),
    );
    _persistOverrides();
    SharedPreferences.getInstance().then((p) => p.setInt(customColorKey, color.toARGB32()));
  }

  Map<String, int> _overridesOf(Brightness b) => b == Brightness.dark ? state.darkOverrides : state.lightOverrides;

  void _setOverrides(Brightness b, Map<String, int> overrides) {
    state = b == Brightness.dark ? state.copyWith(darkOverrides: overrides) : state.copyWith(lightOverrides: overrides);
    SharedPreferences.getInstance().then((p) => p.setString('${schemeOverridesKey}_${b.name}', jsonEncode(overrides)));
  }

  void _persistOverrides() {
    SharedPreferences.getInstance().then((p) {
      p.setString('${schemeOverridesKey}_light', jsonEncode(state.lightOverrides));
      p.setString('${schemeOverridesKey}_dark', jsonEncode(state.darkOverrides));
    });
  }

  /// Overrides one [ColorScheme] property (see [kSchemeColorKeys]) for the given brightness.
  void setSchemeColor(Brightness b, String key, Color color) => _setOverrides(b, {..._overridesOf(b), key: color.toARGB32()});

  void resetSchemeColor(Brightness b, String key) => _setOverrides(b, {..._overridesOf(b)}..remove(key));

  void resetScheme(Brightness b) => _setOverrides(b, {});

  void setLayoutStyle(TLayoutStyle style) {
    state = state.copyWith(layoutStyle: style);
    SharedPreferences.getInstance().then((p) => p.setString(layoutStyleKey, style.name));
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, mode.name);
  }

  Future<void> _savePrimaryColor(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(primaryColorIndexKey, index);
  }
}

class SidebarNotifier extends Notifier<TSidebarMode> {
  @override
  TSidebarMode build() => _initialSidebarMode;

  void toggleSidebar() {
    final nextIndex = (state.index + 1) % TSidebarMode.values.length;
    setMode(TSidebarMode.values[nextIndex]);
  }

  void setMode(TSidebarMode mode) {
    state = mode;
    _saveSidebar(mode);
  }

  Future<void> _saveSidebar(TSidebarMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sidebarModeKey, mode.name);
    await prefs.setBool(sidebarMinifiedKey, mode == TSidebarMode.minified);
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, TThemeState>(() => ThemeNotifier());
final sidebarNotifierProvider = NotifierProvider<SidebarNotifier, TSidebarMode>(() => SidebarNotifier());

class PrimaryColorOption {
  final String name;
  final MaterialColor color;
  const PrimaryColorOption(this.name, this.color);
}

const List<PrimaryColorOption> primaryColorOptions = [
  PrimaryColorOption('Emerald Green', AppColors.emeraldGreen),
  PrimaryColorOption('Classic Teal', AppColors.primary),
  PrimaryColorOption('Indigo Tech', AppColors.indigo),
  PrimaryColorOption('Cyber Violet', AppColors.cyberViolet),
  PrimaryColorOption('Rose Gold', AppColors.roseGold),
  PrimaryColorOption('Amber Gold', AppColors.amberGold),
];

/// Builds a Material-style swatch (50..950) around [base] (used as shade 400/500 midpoint).
MaterialColor _swatchFrom(Color base) {
  Color mix(Color target, double t) => Color.lerp(base, target, t)!;
  final shades = <int, Color>{
    50: mix(Colors.white, 0.92),
    100: mix(Colors.white, 0.8),
    200: mix(Colors.white, 0.6),
    300: mix(Colors.white, 0.3),
    400: base,
    500: mix(Colors.black, 0.12),
    600: mix(Colors.black, 0.25),
    700: mix(Colors.black, 0.4),
    800: mix(Colors.black, 0.55),
    900: mix(Colors.black, 0.7),
    950: mix(Colors.black, 0.82),
  };
  return MaterialColor(base.toARGB32(), shades);
}

/// Override key for the scaffold background (not a [ColorScheme] property).
const String kScaffoldBackgroundKey = 'scaffoldBackground';

/// [ColorScheme] properties that can be overridden, in display order.
const List<String> kSchemeColorKeys = [
  'primary',
  'onPrimary',
  'primaryContainer',
  'onPrimaryContainer',
  'secondary',
  'onSecondary',
  'secondaryContainer',
  'onSecondaryContainer',
  'error',
  'onError',
  'errorContainer',
  'onErrorContainer',
  'surface',
  'surfaceBright',
  'surfaceDim',
  'surfaceContainerLowest',
  'surfaceContainerLow',
  'surfaceContainer',
  'surfaceContainerHigh',
  'surfaceContainerHighest',
  'onSurface',
  'onSurfaceVariant',
  'outline',
  'outlineVariant',
  'shadow',
  'scrim',
  'surfaceTint',
];

/// Returns [scheme] with the ARGB values in [o] (keyed by [kSchemeColorKeys]) applied.
ColorScheme applySchemeOverrides(ColorScheme scheme, Map<String, int> o) {
  Color? v(String k) => o[k] == null ? null : Color(o[k]!);
  return scheme.copyWith(
    primary: v('primary'),
    onPrimary: v('onPrimary'),
    primaryContainer: v('primaryContainer'),
    onPrimaryContainer: v('onPrimaryContainer'),
    secondary: v('secondary'),
    onSecondary: v('onSecondary'),
    secondaryContainer: v('secondaryContainer'),
    onSecondaryContainer: v('onSecondaryContainer'),
    error: v('error'),
    onError: v('onError'),
    errorContainer: v('errorContainer'),
    onErrorContainer: v('onErrorContainer'),
    surface: v('surface'),
    surfaceBright: v('surfaceBright'),
    surfaceDim: v('surfaceDim'),
    surfaceContainerLowest: v('surfaceContainerLowest'),
    surfaceContainerLow: v('surfaceContainerLow'),
    surfaceContainer: v('surfaceContainer'),
    surfaceContainerHigh: v('surfaceContainerHigh'),
    surfaceContainerHighest: v('surfaceContainerHighest'),
    onSurface: v('onSurface'),
    onSurfaceVariant: v('onSurfaceVariant'),
    outline: v('outline'),
    outlineVariant: v('outlineVariant'),
    shadow: v('shadow'),
    scrim: v('scrim'),
    surfaceTint: v('surfaceTint'),
  );
}

/// Reads the [ColorScheme] property named [key].
Color schemeColor(ColorScheme s, String key) => switch (key) {
      'primary' => s.primary,
      'onPrimary' => s.onPrimary,
      'primaryContainer' => s.primaryContainer,
      'onPrimaryContainer' => s.onPrimaryContainer,
      'secondary' => s.secondary,
      'onSecondary' => s.onSecondary,
      'secondaryContainer' => s.secondaryContainer,
      'onSecondaryContainer' => s.onSecondaryContainer,
      'error' => s.error,
      'onError' => s.onError,
      'errorContainer' => s.errorContainer,
      'onErrorContainer' => s.onErrorContainer,
      'surface' => s.surface,
      'surfaceBright' => s.surfaceBright,
      'surfaceDim' => s.surfaceDim,
      'surfaceContainerLowest' => s.surfaceContainerLowest,
      'surfaceContainerLow' => s.surfaceContainerLow,
      'surfaceContainer' => s.surfaceContainer,
      'surfaceContainerHigh' => s.surfaceContainerHigh,
      'surfaceContainerHighest' => s.surfaceContainerHighest,
      'onSurface' => s.onSurface,
      'onSurfaceVariant' => s.onSurfaceVariant,
      'outline' => s.outline,
      'outlineVariant' => s.outlineVariant,
      'shadow' => s.shadow,
      'scrim' => s.scrim,
      'surfaceTint' => s.surfaceTint,
      _ => s.primary,
    };
