import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class to set up mocks for platform channels
class PlatformMocks {
  /// Set up all common platform mocks for testing
  static void setupAll() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestDefaultBinaryMessengerBinding.instance;

    // Mock screen brightness
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('screen_brightness'),
      (call) async {
        if (call.method == 'getScreenBrightness') return 0.5;
        if (call.method == 'setScreenBrightness') return null;
        if (call.method == 'resetScreenBrightness') return null;
        return null;
      },
    );

    // Mock path provider
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => '/tmp',
    );

    // Mock file selector
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/file_selector'),
      (call) async => null,
    );

    // Mock share plus
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/share_plus'),
      (call) async => null,
    );
  }
}
