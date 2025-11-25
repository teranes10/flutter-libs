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

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _initialTheme;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(state);
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, mode.name);
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

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() => ThemeNotifier());
final sidebarNotifierProvider = NotifierProvider<SidebarNotifier, bool>(() => SidebarNotifier());
