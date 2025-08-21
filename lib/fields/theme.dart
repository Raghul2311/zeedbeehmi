import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static const String _themeKey = "theme_mode"; // key of store theme

  ThemeNotifier() : super(ThemeMode.light);
  // toggle b/w light and dark .........
  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(value);
  }

  // save theme mode to shared Preference
  Future<void> _saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.toString().split(".").last);
  }

  // Load theme mode in shared prefrernces
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == "dark") {
      value = ThemeMode.dark;
    } else if (savedTheme == "light") {
      value = ThemeMode.light;
    }
  }
}
