import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeKey = 'te_theme_mode';
final sidebarMinifiedKey = 'te_sidebar_minified';

late final SharedPreferences _prefs;
late final ThemeMode _initialTheme;
late final bool _initialSidebarMinified;

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  _prefs = await SharedPreferences.getInstance();

  _initialTheme = switch (_prefs.getString(themeModeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  _initialSidebarMinified = _prefs.getBool(sidebarMinifiedKey) ?? false;
}

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(super.initialTheme);

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    _saveThemeMode(newMode);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, mode.name);
  }
}

class SidebarNotifier extends StateNotifier<bool> {
  SidebarNotifier(super.initialState);

  void toggleSidebar() {
    final newState = !state;
    state = newState;
    _saveSidebar(newState);
  }

  Future<void> _saveSidebar(bool minified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sidebarMinifiedKey, minified);
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier(_initialTheme));
final sidebarNotifierProvider = StateNotifierProvider<SidebarNotifier, bool>((ref) => SidebarNotifier(_initialSidebarMinified));
