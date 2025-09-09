import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeKey = 'te_theme_mode';
late final SharedPreferences _prefs;
late final ThemeMode _initialTheme;

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  _prefs = await SharedPreferences.getInstance();

  final value = _prefs.getString(themeModeKey);

  _initialTheme = switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
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

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier(_initialTheme));
