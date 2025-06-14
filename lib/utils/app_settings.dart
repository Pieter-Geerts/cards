import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Import for ThemeMode
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  static SharedPreferences? _prefs;
  static const String _languageKey = 'language_code';
  static const String _themeModeKey =
      'theme_mode'; // Key for storing theme mode
  static const String _hasSetLanguageKey = 'has_set_language'; // Track if user has manually set language

  // Supported languages in the app
  static const List<String> supportedLanguages = ['en', 'es', 'nl'];

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Auto-detect device language on first launch
    await _initializeLanguageFromDevice();
  }

  // Initialize language from device if user hasn't set one manually
  static Future<void> _initializeLanguageFromDevice() async {
    final hasSetLanguage = _prefs?.getBool(_hasSetLanguageKey) ?? false;
    
    if (!hasSetLanguage) {
      final deviceLanguage = getDeviceLanguage();
      await _prefs?.setString(_languageKey, deviceLanguage);
    }
  }

  // Get device's default language
  static String getDeviceLanguage() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final deviceLanguageCode = deviceLocale.languageCode;
    
    // Check if device language is supported, otherwise fall back to English
    if (supportedLanguages.contains(deviceLanguageCode)) {
      return deviceLanguageCode;
    } else {
      return 'en'; // Default fallback
    }
  }

  // Get the current language code (with device language detection)
  static String getLanguageCode() {
    return _prefs?.getString(_languageKey) ?? getDeviceLanguage();
  }

  // Check if user has manually set a language
  static bool getHasSetLanguage() {
    return _prefs?.getBool(_hasSetLanguageKey) ?? false;
  }

  // Static method to change language and notify listeners
  static Future<void> setLanguageCodeAndNotify(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
    await _prefs?.setBool(_hasSetLanguageKey, true); // Mark that user has manually set language
    _notifyStaticListeners();
  }

  // Reset language to device default and notify listeners
  static Future<void> resetToDeviceLanguage() async {
    final deviceLanguage = getDeviceLanguage();
    await _prefs?.setString(_languageKey, deviceLanguage);
    await _prefs?.setBool(_hasSetLanguageKey, false); // Mark as not manually set
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
