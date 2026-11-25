import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _key = 'isDark';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // Returns light when nothing has been saved yet.
  static Future<ThemeMode> loadTheme() async {
    final isDark = await _prefs.getBool(_key) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> saveTheme(bool isDark) async {
    await _prefs.setBool(_key, isDark);
  }
}
