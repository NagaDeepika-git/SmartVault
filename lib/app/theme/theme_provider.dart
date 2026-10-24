import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages application ThemeMode state and persistence across restarts.
class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'smartvault_theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_themePrefKey);
      if (modeString != null) {
        if (modeString == 'light') {
          _themeMode = ThemeMode.light;
        } else if (modeString == 'system') {
          _themeMode = ThemeMode.system;
        } else {
          _themeMode = ThemeMode.dark;
        }
        notifyListeners();
      }
    } catch (_) {
      // Fallback to dark if preferences are inaccessible
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.system
              ? 'system'
              : 'dark';
      await prefs.setString(_themePrefKey, modeStr);
    } catch (_) {}
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
