import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/repositories/sqlite_card_repository.dart';
import 'package:cards/utils/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialize test environment for integration tests
Future<void> setupIntegrationTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences for settings
  SharedPreferences.setMockInitialValues({
    'language_code': 'en',
    'theme_mode': 'system',
    'has_set_language': true,
  });

  // Initialize AppSettings
  await AppSettings.init();

  final repository = SqliteCardRepository();
  await repository.deleteAllCards();
}

/// Wrap a widget with necessary providers for testing
/// Provides localization, theme, and navigation support
class IntegrationTestApp extends StatelessWidget {
  final Widget home;
  final List<NavigatorObserver> navigatorObservers;
  final GlobalKey<NavigatorState>? navigatorKey;

  const IntegrationTestApp({
    required this.home,
    this.navigatorObservers = const [],
    this.navigatorKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Just Cards - Integration Tests',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
      navigatorObservers: navigatorObservers,
    );
  }
}

/// Helper for managing test card data
class TestCardDataHelper {
  static const String testQRCodeValue = 'https://example.com/test-qr-123';
  static const String testBarcodeValue = '1234567890123';
  static const String testCardTitle = 'Test Card';
  static const String testCardDescription = 'A test card for e2e testing';

  static Map<String, dynamic> getValidQRCodeData() {
    return {
      'title': 'QR Code Test',
      'description': 'Test QR Code card',
      'code': testQRCodeValue,
      'type': 'QR Code',
    };
  }

  static Map<String, dynamic> getValidBarcodeData() {
    return {
      'title': 'Barcode Test',
      'description': 'Test Barcode card',
      'code': testBarcodeValue,
      'type': 'Barcode',
    };
  }

  static Map<String, dynamic> getScannedBarcodeData() {
    return {
      'title': 'Scanned Barcode Test',
      'description': 'Scanned barcode card',
      'code': testBarcodeValue,
      'type': 'Barcode',
    };
  }

  static Map<String, dynamic> getScannedQrCodeData() {
    return {
      'title': 'Scanned QR Test',
      'description': 'Scanned QR code card',
      'code': testQRCodeValue,
      'type': 'QR Code',
    };
  }

  static Map<String, dynamic> getScannedBarcodeTempData() {
    return {
      'title': 'Temp Barcode Test',
      'description': 'Temporary barcode card',
      'code': testBarcodeValue,
      'type': 'Barcode',
    };
  }

  static Map<String, dynamic> getScannedQrCodeTempData() {
    return {
      'title': 'Temp QR Test',
      'description': 'Temporary QR code card',
      'code': testQRCodeValue,
      'type': 'QR Code',
    };
  }

  static Map<String, dynamic> getValidCustomCardData({
    String? title,
    String? code,
    String? description,
  }) {
    return {
      'title': title ?? 'Custom Test Card',
      'description': description ?? 'Custom card for testing',
      'code': code ?? '9876543210',
      'type': 'QR Code',
    };
  }
}

/// Helper for waiting and synchronizing test UI state
class TestSyncHelper {
  static Future<void> waitForPageTransition(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  static Future<void> waitForSnackBarToDismiss(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  static Future<void> waitForAnimation(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// Wait for a specific finder to appear with retries
  static Future<bool> waitForFinder(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      await tester.pump(interval);
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }

    return false;
  }
}

/// Helper for verifying error states and messages
class TestErrorHandler {
  static Future<void> verifySnackBarMessage(
    WidgetTester tester,
    String expectedMessage,
  ) async {
    expect(
      find.byType(SnackBar),
      findsOneWidget,
      reason: 'SnackBar should be displayed',
    );
    expect(
      find.text(expectedMessage),
      findsOneWidget,
      reason: 'SnackBar should contain: $expectedMessage',
    );
  }

  static Future<void> verifyDialogMessage(
    WidgetTester tester,
    String expectedMessage,
  ) async {
    expect(
      find.byType(AlertDialog),
      findsOneWidget,
      reason: 'Dialog should be displayed',
    );
    expect(
      find.text(expectedMessage),
      findsOneWidget,
      reason: 'Dialog should contain: $expectedMessage',
    );
  }

  static Future<void> dismissSnackBar(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }
}

/// Captures screenshots during integration tests via IntegrationTestWidgetsFlutterBinding.
///
/// Screenshots are stored on the device under the test name and can be pulled
/// with `adb pull /sdcard/Download/screenshots/` after the run.
///
/// Usage:
///   await ScreenshotHelper.capture(tester, 'scan_barcode_entry_page');
class ScreenshotHelper {
  static IntegrationTestWidgetsFlutterBinding? _binding;
  static bool _surfaceConverted = false;

  static IntegrationTestWidgetsFlutterBinding get binding {
    _binding ??= IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    return _binding!;
  }

  /// Call this once at the start of a test that will take screenshots.
  /// Calling it more than once per test is a no-op.
  static Future<void> setUp(WidgetTester tester) async {
    if (_surfaceConverted) return;
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }

  /// Reset between tests so each test starts with a fresh surface state.
  static void reset() {
    _surfaceConverted = false;
  }

  /// Captures a screenshot with [name] as the file stem.
  /// Name should be snake_case without extension (e.g. 'scan_barcode_form').
  /// Automatically calls [setUp] if not already done.
  static Future<void> capture(WidgetTester tester, String name) async {
    await setUp(tester);
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }
}
