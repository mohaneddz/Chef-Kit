import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Theme mode state
enum AppThemeMode { light, dark, system }

/// ThemeCubit manages the app's theme (light/dark) and persists it
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(ThemeMode? savedMode) : super(savedMode ?? ThemeMode.light);

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _key = 'app_theme_mode';

  /// Load saved theme from storage
  static Future<ThemeMode?> loadSavedTheme() async {
    try {
      final savedValue = await _storage.read(key: _key);
      if (savedValue == null) return null;

      switch (savedValue) {
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.light;
      }
    } catch (e) {
      return null;
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _saveTheme(newMode);
    emit(newMode);
  }

  /// Set specific theme mode
  void setTheme(ThemeMode mode) {
    _saveTheme(mode);
    emit(mode);
  }

  /// Check if current theme is dark
  bool get isDark => state == ThemeMode.dark;

  /// Save theme to storage
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      String value;
      switch (mode) {
        case ThemeMode.dark:
          value = 'dark';
          break;
        case ThemeMode.system:
          value = 'system';
          break;
        default:
          value = 'light';
      }
      await _storage.write(key: _key, value: value);
    } catch (e) {
      // Ignore storage errors
    }
  }
}
