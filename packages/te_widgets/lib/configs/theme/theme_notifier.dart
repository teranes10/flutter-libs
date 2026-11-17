import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:te_widgets/te_widgets.dart';
import '../../helpers/image-storage/image_storage.dart';

final themeModeKey = 'te_theme_mode';
final sidebarMinifiedKey = 'te_sidebar_minified';
final sidebarModeKey = 'te_sidebar_mode';
final primaryColorIndexKey = 'te_primary_color_index';
final customColorKey = 'te_custom_color';
final schemeOverridesKey = 'te_scheme_overrides';
final layoutStyleKey = 'te_layout_style';
final glassKey = 'te_glass';
final glassColorsKey = 'te_glass_colors';
final glassAnimatedKey = 'te_glass_animated';
final glassStaticKey = 'te_glass_static';
final glassLookKey = 'te_glass_look';
final glassImageBlurKey = 'te_glass_image_blur';
final glassImageDimKey = 'te_glass_image_dim';
final glassImageHashKey = 'te_glass_image_hash';
final glassIdleKey = 'te_glass_idle_seconds';

ThemeMode _initialTheme = ThemeMode.light;
TSidebarMode _initialSidebarMode = TSidebarMode.full;
int _initialPrimaryColorIndex = 0;
Color? _initialCustomColor;
Map<String, int> _initialLightOverrides = {};
Map<String, int> _initialDarkOverrides = {};
TLayoutStyle _initialLayoutStyle = TLayoutStyle.layout1;
bool _initialGlass = true;
List<Color>? _initialGlassColors;
bool _initialGlassAnimated = true;
bool _initialGlassStatic = false;
int _initialGlassIdle = 10;
double _initialGlassImageBlur = 3;
int _initialGlassImageDim = 30;
String? _initialGlassImageHash;
String? _initialGlassAsset;
String? _initialGlassAssetHash;
TGlassLook _initialGlassLook = TGlassLook.liquid;

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

  /// Mode to hand to MaterialApp. Glass currently ships dark-only: with glass on, light and dark both render dark
  /// (the light glass look isn't finished). The stored [themeMode] is kept, so it applies again when glass is off.
  ThemeMode get effectiveThemeMode => glass ? ThemeMode.dark : themeMode;
  final int primaryColorIndex;
  final TLayoutStyle layoutStyle;

  /// Global liquid-glass mode for cards and tiles (see [TWidgetThemeExtension.glass]).
  final bool glass;

  /// Custom colour mix for the glass background blobs; null uses the theme palette.
  final List<Color>? glassColors;

  /// Glass background reacts to the pointer and drifts on its own after 30s idle. Turn off to save resources.
  final bool glassAnimated;

  /// Frosted (flat) or liquid (raised, thick) glass.
  final TGlassLook glassLook;

  /// Seconds the pointer must rest before the background starts drifting on its own.
  final int glassIdleSeconds;

  /// Use a static image instead of the animated blobs (see [glassImageBytes] / [glassImageAsset]).
  final bool glassStatic;

  /// Blur (sigma 0-30) applied to the static background image, so photos don't compete with the content.
  final double glassImageBlur;

  /// Darkening (0-80 %) laid over the static background image.
  final int glassImageDim;

  /// BlurHash of the user's image: shown as an instant preview while the stored image loads.
  final String? glassImageHash;

  /// Image picked by the user, kept in IndexedDB. Wins over [glassImageAsset].
  final Uint8List? glassImageBytes;

  /// Local copy of [glassImageAsset] (stored on first load, so later launches skip the download).
  final Uint8List? glassAssetBytes;

  /// BlurHash of [glassImageAsset].
  final String? glassAssetHash;

  /// Asset path set from code, used when the user has not picked an image.
  final String? glassImageAsset;

  /// User-picked accent; overrides [primaryColorIndex] when set.
  final Color? customColor;

  /// Per-property [ColorScheme] overrides (key = property name, value = ARGB) for each brightness.
  final Map<String, int> lightOverrides;
  final Map<String, int> darkOverrides;

  MaterialColor get primaryColor => customColor != null ? _swatchFrom(customColor!) : primaryColorOptions[primaryColorIndex].color;

  /// Values derived from a custom accent (e.g. a readable `onPrimary`); user overrides win over these.
  Map<String, int> _accentDerived(ColorScheme base) {
    final accent = primaryColor.shade500;
    return {
      if (customColor != null) 'onPrimary': (customColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white).toARGB32(),
      ..._tintedKeys.map((k, t) => MapEntry(k, Color.lerp(schemeColor(base, k), accent, t)!.toARGB32())),
      'surfaceTint': accent.withValues(alpha: 0.1).toARGB32(),
      // Text colour: a deep shade of the accent in light mode, a pale shade in dark mode (keeps contrast).
      'onSurface': (base.brightness == Brightness.dark
              ? Color.lerp(base.onSurface, primaryColor.shade100, 0.6)!
              : Color.lerp(Colors.black, primaryColor.shade900, 0.25)!)
          .toARGB32(),
      // Outlines: clearly accent-coloured rather than grey; the variant is a bit darker than before.
      'outline': Color.lerp(Color.lerp(base.outline, accent, 0.4)!, Colors.black, 0.04)!.toARGB32(),
      'outlineVariant': Color.lerp(Color.lerp(base.outlineVariant, accent, 0.3)!, Colors.black, 0.05)!.toARGB32(),
      // Shadow / scrim: near-black with an accent undertone (opacity is applied by the widgets using them).
      'shadow': Color.lerp(Colors.black, primaryColor.shade900, 0.3)!.toARGB32(),
      'scrim': Color.lerp(Colors.black, primaryColor.shade900, 0.2)!.toARGB32(),
      // Secondary text: light grey with a hint of accent, clearly lighter than onSurface for hierarchy.
      'onSurfaceVariant': (base.brightness == Brightness.dark
              ? Color.lerp(Colors.grey.shade500, primaryColor.shade200, 0.15)!
              : Color.lerp(Colors.grey.shade600, primaryColor.shade500, 0.12)!)
          .toARGB32(),
    };
  }

  /// Scaffold background: user override, else the theme default (white in light mode, accent-tinted in dark).
  Color? _background(Map<String, int> overrides, Color base) {
    final o = overrides[kScaffoldBackgroundKey];
    if (o != null) return Color(o);
    // Same hue as the accent so ground and accent read as one palette; cards (near-white surfaces) sit above it.
    final dark = ThemeData.estimateBrightnessForColor(base) == Brightness.dark;
    return dark ? Color.lerp(base, primaryColor.shade500, 0.06) : Colors.white;
  }

  static const _tintedKeys = <String, double>{
    'surfaceDim': 0.04,
    'surfaceContainerLowest': 0.02,
    'surfaceContainerLow': 0.03,
    'surfaceContainer': 0.05,
    'surfaceContainerHigh': 0.06,
    'surfaceContainerHighest': 0.08,
  };

  /// The app theme; with glass on, its schemes are swapped for glass-tuned ones ([TGlassStyle.scheme]) so
  /// the regular (non-glass) palette stays untouched.
  TAppTheme get theme {
    final t = _solidTheme;
    if (!glass) return t;
    return TAppTheme(
      lightScheme: TGlassStyle.scheme(t.lightScheme),
      darkScheme: TGlassStyle.scheme(t.darkScheme),
      widgetThemeBuilder: t.widgetThemeBuilder,
      lightBackground: t.lightBackground,
      darkBackground: t.darkBackground,
    );
  }

  TAppTheme get _solidTheme {
    final base = layoutStyle == TLayoutStyle.layout2
        ? TAppTheme.defaultTheme2(primary: primaryColor)
        : TAppTheme.defaultTheme(primary: primaryColor);
    // Glass is a global switch: stamped onto every widget theme the builder produces.
    final baseBuilder = base.widgetThemeBuilder;
    final builder = glass ? (ColorScheme c) => baseBuilder(c).copyWith(glass: TGlassStyle(look: glassLook)) : baseBuilder;
    if (lightOverrides.isEmpty && darkOverrides.isEmpty && customColor == null) {
      return glass ? base.copyWith(widgetThemeBuilder: builder) : base;
    }
    return TAppTheme(
      lightScheme: applySchemeOverrides(base.lightScheme, {..._accentDerived(base.lightScheme), ...lightOverrides}),
      darkScheme: applySchemeOverrides(base.darkScheme, {..._accentDerived(base.darkScheme), ...darkOverrides}),
      widgetThemeBuilder: builder,
      lightBackground: _background(lightOverrides, AppColors.lightBackground),
      darkBackground: _background(darkOverrides, AppColors.darkBackground),
    );
  }

  const TThemeState({
    required this.themeMode,
    required this.primaryColorIndex,
    this.layoutStyle = TLayoutStyle.layout1,
    this.glass = true,
    this.glassColors,
    this.glassAnimated = true,
    this.glassLook = TGlassLook.liquid,
    this.glassIdleSeconds = 10,
    this.glassStatic = false,
    this.glassImageBlur = 3,
    this.glassImageDim = 30,
    this.glassImageHash,
    this.glassImageBytes,
    this.glassImageAsset,
    this.glassAssetBytes,
    this.glassAssetHash,
    this.customColor,
    this.lightOverrides = const {},
    this.darkOverrides = const {},
  });

  TThemeState copyWith({
    ThemeMode? themeMode,
    int? primaryColorIndex,
    TLayoutStyle? layoutStyle,
    bool? glass,
    List<Color>? glassColors,
    bool clearGlassColors = false,
    bool? glassAnimated,
    TGlassLook? glassLook,
    int? glassIdleSeconds,
    bool? glassStatic,
    double? glassImageBlur,
    int? glassImageDim,
    String? glassImageHash,
    Uint8List? glassImageBytes,
    bool clearGlassImage = false,
    String? glassImageAsset,
    Uint8List? glassAssetBytes,
    String? glassAssetHash,
    Color? customColor,
    bool clearCustomColor = false,
    Map<String, int>? lightOverrides,
    Map<String, int>? darkOverrides,
  }) {
    return TThemeState(
      lightOverrides: lightOverrides ?? this.lightOverrides,
      darkOverrides: darkOverrides ?? this.darkOverrides,
      customColor: clearCustomColor ? null : (customColor ?? this.customColor),
      themeMode: themeMode ?? this.themeMode,
      primaryColorIndex: primaryColorIndex ?? this.primaryColorIndex,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      glass: glass ?? this.glass,
      glassColors: clearGlassColors ? null : (glassColors ?? this.glassColors),
      glassAnimated: glassAnimated ?? this.glassAnimated,
      glassLook: glassLook ?? this.glassLook,
      glassIdleSeconds: glassIdleSeconds ?? this.glassIdleSeconds,
      glassStatic: glassStatic ?? this.glassStatic,
      glassImageBlur: glassImageBlur ?? this.glassImageBlur,
      glassImageDim: glassImageDim ?? this.glassImageDim,
      glassImageHash: clearGlassImage ? null : (glassImageHash ?? this.glassImageHash),
      glassImageBytes: clearGlassImage ? null : (glassImageBytes ?? this.glassImageBytes),
      glassImageAsset: glassImageAsset ?? this.glassImageAsset,
      glassAssetBytes: glassAssetBytes ?? this.glassAssetBytes,
      glassAssetHash: glassAssetHash ?? this.glassAssetHash,
    );
  }
}

/// Key under which the asset's bytes and BlurHash are kept locally (see `ThemeNotifier._prepareGlassAsset`).
String _glassAssetKey(String asset) => 'te_glass_asset_${TImageStorage.urlToKey(asset)}';

/// Call before `runApp`. Every parameter is a *default from code*: it applies until the user changes that setting
/// in the customizer (their saved choice always wins), so you can ship your own look without locking it.
///
/// ```dart
/// await initializeApp(
///   themeMode: ThemeMode.dark,
///   primaryColor: const Color(0xFF3B82C4),
///   glassColors: [Color(0xFF3B6EA5), Color(0xFF5B8DB8), Color(0xFF7AA5C9)],
///   glassImageAsset: 'assets/bg.jpg',
/// );
/// ```
///
/// - [prefs]: pass your own `SharedPreferences` instance (e.g. in tests).
/// - [themeMode], [sidebarMode], [layoutStyle]: basic layout and theme defaults.
/// - [primaryColor] (any colour) or [primaryColorIndex] (an entry of the built-in accent list): the accent.
/// - [glass]: liquid-glass mode on/off. [glassLook]: frosted or liquid.
/// - [glassColors]: colour mix of the animated glass background. [glassAnimated]: pointer reaction and auto drift.
///   [glassIdleSeconds]: pointer rest time before auto drift starts.
/// - [glassStatic]: use a static image instead of the animated blobs. [glassImageBlur] (0-30) and [glassImageDim]
///   (0-80 %) soften and darken that image.
/// - [glassImageAsset] (e.g. `assets/bg.jpg`): the static background image. It implies [glassStatic] unless you set it.
///   On web an asset is a network download, so it is fetched once, stored locally (IndexedDB) and read from there on
///   later launches; the first time it also produces a BlurHash and the matching accent colours.
Future<void> initializeApp({
  SharedPreferences? prefs,
  ThemeMode? themeMode,
  TSidebarMode? sidebarMode,
  TLayoutStyle? layoutStyle,
  Color? primaryColor,
  int? primaryColorIndex,
  bool? glass,
  TGlassLook? glassLook,
  List<Color>? glassColors,
  bool? glassAnimated,
  int? glassIdleSeconds,
  bool? glassStatic,
  double? glassImageBlur,
  int? glassImageDim,
  String? glassImageAsset,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final p = prefs ?? await SharedPreferences.getInstance();

  _initialTheme = switch (p.getString(themeModeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => themeMode ?? ThemeMode.light,
  };

  final savedMode = p.getString(sidebarModeKey);
  if (savedMode != null) {
    _initialSidebarMode = TSidebarMode.values.firstWhere(
      (m) => m.name == savedMode,
      orElse: () => sidebarMode ?? TSidebarMode.full,
    );
  } else if (p.containsKey(sidebarMinifiedKey)) {
    _initialSidebarMode = (p.getBool(sidebarMinifiedKey) ?? false) ? TSidebarMode.minified : TSidebarMode.full;
  } else {
    _initialSidebarMode = sidebarMode ?? TSidebarMode.full;
  }

  _initialPrimaryColorIndex = p.getInt(primaryColorIndexKey) ?? primaryColorIndex ?? 0;
  final customValue = p.getInt(customColorKey);
  // A code-set primaryColor applies only while the user has not picked an accent (swatch or custom) themselves.
  _initialCustomColor =
      customValue != null ? Color(customValue) : (p.containsKey(primaryColorIndexKey) || primaryColorIndex != null ? null : primaryColor);
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
    orElse: () => layoutStyle ?? TLayoutStyle.layout1,
  );
  _initialGlass = p.getBool(glassKey) ?? glass ?? true;
  _initialGlassColors = p.getStringList(glassColorsKey)?.map((e) => Color(int.parse(e))).toList() ?? glassColors;
  _initialGlassAnimated = p.getBool(glassAnimatedKey) ?? glassAnimated ?? true;
  _initialGlassAsset = glassImageAsset;
  _initialGlassAssetHash = glassImageAsset == null ? null : p.getString('${_glassAssetKey(glassImageAsset)}_hash');
  // An asset given with no saved choice starts on the static image.
  _initialGlassStatic = p.getBool(glassStaticKey) ?? glassStatic ?? (glassImageAsset != null);
  _initialGlassIdle = p.getInt(glassIdleKey) ?? glassIdleSeconds ?? 10;
  _initialGlassImageBlur = p.getDouble(glassImageBlurKey) ?? glassImageBlur ?? 3;
  _initialGlassImageDim = p.getInt(glassImageDimKey) ?? glassImageDim ?? 30;
  _initialGlassImageHash = p.getString(glassImageHashKey);
  _initialGlassLook = TGlassLook.values.firstWhere(
    (l) => l.name == p.getString(glassLookKey),
    orElse: () => glassLook ?? TGlassLook.liquid,
  );
}

class ThemeNotifier extends Notifier<TThemeState> {
  @override
  TThemeState build() {
    final s = TThemeState(
      themeMode: _initialTheme,
      primaryColorIndex: _initialPrimaryColorIndex,
      customColor: _initialCustomColor,
      lightOverrides: _initialLightOverrides,
      darkOverrides: _initialDarkOverrides,
      layoutStyle: _initialLayoutStyle,
      glass: _initialGlass,
      glassColors: _initialGlassColors,
      glassAnimated: _initialGlassAnimated,
      glassLook: _initialGlassLook,
      glassIdleSeconds: _initialGlassIdle,
      glassStatic: _initialGlassStatic,
      glassImageBlur: _initialGlassImageBlur,
      glassImageDim: _initialGlassImageDim,
      glassImageHash: _initialGlassImageHash,
      glassImageAsset: _initialGlassAsset,
      glassAssetHash: _initialGlassAssetHash,
    );
    // The user's stored image loads after the first state is in place.
    Future.microtask(() async {
      final bytes = await TGlassImageStore.load();
      if (bytes != null) state = state.copyWith(glassImageBytes: bytes);
    });
    Future.microtask(_prepareGlassAsset);
    return s;
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

  void setGlass(bool value) {
    state = state.copyWith(glass: value);
    SharedPreferences.getInstance().then((p) => p.setBool(glassKey, value));
  }

  /// Gets the code-set asset's bytes: from local storage when stored before, else from the asset bundle (a network
  /// download on web), storing them. The first time only, it also makes the BlurHash and the matching accent colours
  /// (unless the user already has their own image).
  Future<void> _prepareGlassAsset() async {
    final asset = state.glassImageAsset;
    if (asset == null) return;
    final key = _glassAssetKey(asset);
    Uint8List? bytes;
    try {
      bytes = await TImageStorage.loadImageByKey(key);
    } catch (_) {}
    if (bytes != null) {
      state = state.copyWith(glassAssetBytes: bytes);
      return;
    }
    try {
      bytes = (await rootBundle.load(asset)).buffer.asUint8List();
    } catch (_) {
      return;
    }
    state = state.copyWith(glassAssetBytes: bytes);
    try {
      await TImageStorage.storeImage(key, bytes);
    } catch (_) {}

    final hash = await TBlurHash.fromImageBytes(bytes);
    if (hash != null) {
      state = state.copyWith(glassAssetHash: hash);
      unawaited(SharedPreferences.getInstance().then((p) => p.setString('${key}_hash', hash)));
    }
    if (state.glassImageHash == null && state.customColor == null) {
      final palette = await TGlassImagePalette.fromBytes(bytes);
      if (palette != null) {
        setCustomColor(palette.primary);
        for (final b in Brightness.values) {
          setSchemeColor(b, 'secondary', palette.secondary);
        }
        setGlassColors(palette.mix);
      }
    }
  }

  void setGlassColors(List<Color> colors) {
    state = state.copyWith(glassColors: colors);
    SharedPreferences.getInstance().then((p) => p.setStringList(glassColorsKey, [for (final c in colors) '${c.toARGB32()}']));
  }

  void resetGlassColors() {
    state = state.copyWith(clearGlassColors: true);
    SharedPreferences.getInstance().then((p) => p.remove(glassColorsKey));
  }

  void setGlassAnimated(bool value) {
    state = state.copyWith(glassAnimated: value);
    SharedPreferences.getInstance().then((p) => p.setBool(glassAnimatedKey, value));
  }

  void setGlassImageBlur(double v) {
    state = state.copyWith(glassImageBlur: v);
    SharedPreferences.getInstance().then((p) => p.setDouble(glassImageBlurKey, v));
  }

  void setGlassImageDim(int v) {
    state = state.copyWith(glassImageDim: v);
    SharedPreferences.getInstance().then((p) => p.setInt(glassImageDimKey, v));
  }

  void setGlassLook(TGlassLook look) {
    state = state.copyWith(glassLook: look);
    SharedPreferences.getInstance().then((p) => p.setString(glassLookKey, look.name));
  }

  void setGlassIdleSeconds(int seconds) {
    state = state.copyWith(glassIdleSeconds: seconds);
    SharedPreferences.getInstance().then((p) => p.setInt(glassIdleKey, seconds));
  }

  /// Switches between the animated blobs and a static image.
  void setGlassStatic(bool value) {
    state = state.copyWith(glassStatic: value);
    SharedPreferences.getInstance().then((p) => p.setBool(glassStaticKey, value));
  }

  /// Static background from an asset (e.g. `assets/bg.jpg`); call from code at startup. Also switches to image mode.
  void setGlassImageAsset(String asset) {
    state = state.copyWith(glassImageAsset: asset, glassStatic: true);
    unawaited(_prepareGlassAsset());
  }

  /// Stores [bytes] in IndexedDB and uses them as the static glass background.
  Future<void> setGlassImageBytes(Uint8List bytes) async {
    state = state.copyWith(glassImageBytes: bytes, glassStatic: true);
    unawaited(SharedPreferences.getInstance().then((p) => p.setBool(glassStaticKey, true)));
    await TGlassImageStore.save(bytes);

    // BlurHash for an instant preview on the next load.
    final hash = await TBlurHash.fromImageBytes(bytes);
    if (hash != null) {
      state = state.copyWith(glassImageHash: hash);
      unawaited(SharedPreferences.getInstance().then((p) => p.setString(glassImageHashKey, hash)));
    }

    // Matching theme colours: accent from the image's strongest colour, secondary from the next distinct one, and
    // the whole mix for the animated blobs.
    final palette = await TGlassImagePalette.fromBytes(bytes);
    if (palette != null) {
      setCustomColor(palette.primary);
      for (final b in Brightness.values) {
        setSchemeColor(b, 'secondary', palette.secondary);
      }
      setGlassColors(palette.mix);
    }
  }

  Future<void> clearGlassImage() async {
    state = state.copyWith(clearGlassImage: true);
    unawaited(SharedPreferences.getInstance().then((p) => p.remove(glassImageHashKey)));
    await TGlassImageStore.clear();
  }

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
