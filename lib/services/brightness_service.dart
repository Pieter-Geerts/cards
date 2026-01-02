import 'package:screen_brightness/screen_brightness.dart';

/// Lightweight wrapper around `ScreenBrightness` to centralize brightness
/// calls and provide an injectable test hook for widget tests.
class BrightnessService {
  BrightnessService._();

  static Future<double?> Function()? testGetHook;
  static Future<void> Function(double)? testSetHook;

  static Future<double?> current() async {
    if (testGetHook != null) return testGetHook!();
    try {
      final sb = ScreenBrightness();
      return await sb.current;
    } catch (_) {
      return null;
    }
  }

  static Future<void> set(double value) async {
    if (testSetHook != null) return testSetHook!(value);
    final sb = ScreenBrightness();
    await sb.setApplicationScreenBrightness(value);
  }
}
