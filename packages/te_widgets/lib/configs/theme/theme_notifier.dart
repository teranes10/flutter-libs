import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

final themeModeKey = 'te_theme_mode';
final sidebarMinifiedKey = 'te_sidebar_minified';
final primaryColorIndexKey = 'te_primary_color_index';

late final SharedPreferences _prefs;
late final ThemeMode _initialTheme;
late final bool _initialSidebarMinified;
late final int _initialPrimaryColorIndex;

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

  _prefs = prefs ?? await SharedPreferences.getInstance();

  _initialTheme = switch (_prefs.getString(themeModeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  _initialSidebarMinified = _prefs.getBool(sidebarMinifiedKey) ?? false;
  _initialPrimaryColorIndex = _prefs.getInt(primaryColorIndexKey) ?? 0;
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

class SidebarNotifier extends Notifier<bool> {
  @override
  bool build() => _initialSidebarMinified;

  void toggleSidebar() {
    state = !state;
    _saveSidebar(state);
  }

  Future<void> _saveSidebar(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sidebarMinifiedKey, value);
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, TThemeState>(() => ThemeNotifier());
final sidebarNotifierProvider = NotifierProvider<SidebarNotifier, bool>(() => SidebarNotifier());

class PrimaryColorOption {
  final String name;
  final MaterialColor color;
  const PrimaryColorOption(this.name, this.color);
}

const List<PrimaryColorOption> primaryColorOptions = [
  PrimaryColorOption('Classic Teal', AppColors.primary),
  PrimaryColorOption('Indigo Tech', AppColors.indigo),
  PrimaryColorOption('Cyber Violet', AppColors.cyberViolet),
  PrimaryColorOption('Emerald Green', AppColors.emeraldGreen),
  PrimaryColorOption('Rose Gold', AppColors.roseGold),
  PrimaryColorOption('Amber Gold', AppColors.amberGold),
];
