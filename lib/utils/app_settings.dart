import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  static SharedPreferences? _prefs;
  static const String _languageKey = 'language_code';

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get the current language code (default to 'en')
  static String getLanguageCode() {
    return _prefs?.getString(_languageKey) ?? 'en';
  }

  // Change the language code
  Future<void> setLanguageCode(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
    notifyListeners(); // Notify listeners about the change
  }

  // Static method to change language and notify listeners (alternative approach)
  // This is closer to what your existing main.dart and settings_page.dart expect
  // if AppSettings is not used as an instance via a provider.
  static List<VoidCallback> _listeners = [];

  static Future<void> setLanguageCodeAndNotify(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
    _notifyStaticListeners();
  }

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
}
