import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

final themeModeKey = 'te_theme_mode';
final sidebarMinifiedKey = 'te_sidebar_minified';
final sidebarModeKey = 'te_sidebar_mode';
final primaryColorIndexKey = 'te_primary_color_index';

ThemeMode _initialTheme = ThemeMode.system;
TSidebarMode _initialSidebarMode = TSidebarMode.full;
int _initialPrimaryColorIndex = 0;

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

  MaterialColor get primaryColor => primaryColorOptions[primaryColorIndex].color;

  const TThemeState({
    required this.themeMode,
    required this.primaryColorIndex,
  });

  TThemeState copyWith({
    ThemeMode? themeMode,
    int? primaryColorIndex,
  }) {
    return TThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColorIndex: primaryColorIndex ?? this.primaryColorIndex,
    );
  }
}

Future<void> initializeApp([SharedPreferences? prefs]) async {
  WidgetsFlutterBinding.ensureInitialized();

  final p = prefs ?? await SharedPreferences.getInstance();

  _initialTheme = switch (p.getString(themeModeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
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
}

class ThemeNotifier extends Notifier<TThemeState> {
  @override
  TThemeState build() {
    return TThemeState(
      themeMode: _initialTheme,
      primaryColorIndex: _initialPrimaryColorIndex,
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

  void selectColor(int index) {
    if (index >= 0 && index < primaryColorOptions.length) {
      state = state.copyWith(primaryColorIndex: index);
      _savePrimaryColor(index);
    }
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
