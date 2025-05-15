import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Import for ThemeMode
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  static SharedPreferences? _prefs;
  static const String _languageKey = 'language_code';
  static const String _themeModeKey =
      'theme_mode'; // Key for storing theme mode

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get the current language code (default to 'en')
  static String getLanguageCode() {
    return _prefs?.getString(_languageKey) ?? 'en';
  }

  // Static method to change language and notify listeners
  static Future<void> setLanguageCodeAndNotify(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
    _notifyStaticListeners();
  }

  // Get the current theme mode (default to 'system')
  static String getThemeMode() {
    return _prefs?.getString(_themeModeKey) ?? 'system'; // Default to system
  }

  // Static method to change theme mode and notify listeners
  static Future<void> setThemeModeAndNotify(String themeMode) async {
    await _prefs?.setString(_themeModeKey, themeMode);
    _notifyStaticListeners();
  }

  // Static listener management
  static final List<VoidCallback> _listeners = [];

  static void addStaticListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeStaticListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyStaticListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Instance methods (not used by current static listener pattern but part of ChangeNotifier)
  Future<void> setLanguageCode(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(String themeMode) async {
    await _prefs?.setString(_themeModeKey, themeMode);
    notifyListeners();
  }
}
