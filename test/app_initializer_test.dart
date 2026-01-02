import 'package:cards/main.dart';
import 'package:cards/utils/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Use SharedPreferences.setMockInitialValues instead of Mockito
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppInitializer Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'supported_languages': ['en', 'es', 'nl'],
        'language_code': 'en',
        'theme_mode': 'system',
      });

      await AppSettings.init();
    });

    tearDown(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('MyApp renders with MaterialApp', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      await tester.pump(const Duration(milliseconds: 100));

      // Should render MaterialApp
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('App initializes without throwing', (
      WidgetTester tester,
    ) async {
      expect(() => tester.pumpWidget(const TestApp()), returnsNormally);
    });

    testWidgets('Scaffold appears after initialization', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TestApp());
      await tester.pump(const Duration(milliseconds: 100));
      // After initialization, the app should listen to settings changes
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Theme Mode Conversion Tests', () {
    test('Converts "light" to ThemeMode.light', () {
      expect(_getThemeModeFromString('light'), equals(ThemeMode.light));
    });

    test('Converts "dark" to ThemeMode.dark', () {
      expect(_getThemeModeFromString('dark'), equals(ThemeMode.dark));
    });

    test('Converts "system" to ThemeMode.system', () {
      expect(_getThemeModeFromString('system'), equals(ThemeMode.system));
    });

    test('Defaults unknown values to ThemeMode.system', () {
      expect(_getThemeModeFromString('invalid'), equals(ThemeMode.system));
      expect(_getThemeModeFromString(''), equals(ThemeMode.system));
    });
  });
}

// Helper function for testing (mirrors the one in main.dart)
ThemeMode _getThemeModeFromString(String themeModeString) {
  switch (themeModeString) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}
