import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themePreferenceKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoaded = false;
  bool _isDisposed = false;

  ThemeMode get themeMode => _themeMode;

  bool get isLoaded => _isLoaded;

  Future<void> loadThemeMode() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedTheme = preferences.getString(_themePreferenceKey);

      _themeMode = _themeModeFromString(savedTheme);
    } catch (_) {
      _themeMode = ThemeMode.system;
    } finally {
      _isLoaded = true;
      _notifySafely();
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    _notifySafely();

    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setString(
        _themePreferenceKey,
        _themeModeToString(themeMode),
      );
    } catch (_) {
      // Theme still changes for the current session.
    }
  }

  Future<void> cycleThemeMode() async {
    final nextThemeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };

    await setThemeMode(nextThemeMode);
  }

  IconData get icon {
    return switch (_themeMode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };
  }

  String get label {
    return switch (_themeMode) {
      ThemeMode.system => 'System theme',
      ThemeMode.light => 'Light theme',
      ThemeMode.dark => 'Dark theme',
    };
  }

  ThemeMode _themeModeFromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  String _themeModeToString(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
