import 'package:cards/models/card_item.dart';
import 'package:cards/services/error_handling_service.dart';
import 'package:cards/utils/app_settings.dart';
import 'package:cards/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
// Use SharedPreferences.setMockInitialValues instead of Mockito mocks
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization Logic Tests', () {
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

    test('AppSettings initializes successfully', () {
      final languageCode = AppSettings.getLanguageCode();
      expect(languageCode, isNotEmpty);
    });

    test('AppSettings returns supported language code', () {
      final languageCode = AppSettings.getLanguageCode();
      expect(AppSettings.supportedLanguages.contains(languageCode), true);
    });

    test('AppSettings default language is en or device language', () {
      final languageCode = AppSettings.getLanguageCode();
      expect(['en', 'es', 'nl'].contains(languageCode), true);
    });
  });

  group('Card Loading and Error Handling', () {
    test('Empty card list is valid result', () async {
      final testCards = <CardItem>[];
      expect(testCards, isEmpty);
    });

    test('Failure can be created with message', () {
      final failure = Failure('Database error');
      expect(failure.message, 'Database error');
    });

    test('Multiple failures with different messages', () {
      final failure1 = Failure('Error 1');
      final failure2 = Failure('Error 2');

      expect(failure1.message, isNot(failure2.message));
    });
  });

  group('Locale and Theme Configuration', () {
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

    test('AppSettings stores language code in memory', () {
      const testLanguage = 'es';
      AppSettings.setLanguageCodeAndNotify(testLanguage);

      final retrievedLanguage = AppSettings.getLanguageCode();
      // After setting, it should be the new language
      expect(retrievedLanguage, testLanguage);
    });

    test('AppSettings stores theme mode in memory', () {
      const testTheme = 'dark';
      AppSettings.setThemeModeAndNotify(testTheme);

      final retrievedTheme = AppSettings.getThemeMode();
      // After setting, it should be the new theme
      expect(retrievedTheme, testTheme);
    });

    test('Theme mode defaults to valid value', () async {
      final themeMode = AppSettings.getThemeMode();
      expect(['light', 'dark', 'system'].contains(themeMode), true);
    });
  });

  group('Error Handling Service Integration', () {
    test('ErrorHandlingService.instance is singleton', () {
      final instance1 = ErrorHandlingService.instance;
      final instance2 = ErrorHandlingService.instance;

      expect(instance1, same(instance2));
    });

    test('ErrorHandlingService handles errors without throwing', () {
      final errorService = ErrorHandlingService.instance;

      expect(() {
        errorService.handleError(
          Exception('Test error'),
          StackTrace.current,
          context: 'Test context',
        );
      }, returnsNormally);
    });

    test('ErrorHandlingService handles fatal errors', () {
      final errorService = ErrorHandlingService.instance;

      expect(() {
        errorService.handleError(
          Exception('Fatal error'),
          StackTrace.current,
          context: 'Fatal context',
          isFatal: true,
        );
      }, returnsNormally);
    });

    test('ErrorHandlingService handles errors with additional data', () {
      final errorService = ErrorHandlingService.instance;

      expect(() {
        errorService.handleError(
          Exception('Test'),
          StackTrace.current,
          context: 'Test',
          additionalData: {'key': 'value', 'code': 123},
        );
      }, returnsNormally);
    });
  });

  group('Settings Change Notifications', () {
    test('AppSettings notifies listeners on language change', () async {
      bool listenerCalled = false;

      AppSettings.addStaticListener(() {
        listenerCalled = true;
      });

      await AppSettings.setLanguageCodeAndNotify('nl');

      // Note: Depending on implementation, listener might be called immediately
      // or on next frame. This test verifies the mechanism works.
      expect(listenerCalled, true);

      AppSettings.removeStaticListener(() {});
    });

    test('AppSettings notifies listeners on theme change', () async {
      bool listenerCalled = false;

      AppSettings.addStaticListener(() {
        listenerCalled = true;
      });

      await AppSettings.setThemeModeAndNotify('light');

      expect(listenerCalled, true);

      AppSettings.removeStaticListener(() {});
    });

    test('Removed listeners do not get called', () async {
      int callCount = 0;

      void listener() {
        callCount++;
      }

      AppSettings.addStaticListener(listener);
      await AppSettings.setLanguageCodeAndNotify('es');

      AppSettings.removeStaticListener(listener);
      await AppSettings.setLanguageCodeAndNotify('nl');

      // callCount should be 1 (only from first change)
      expect(callCount, 1);
    });
  });

  group('Initialization State Management', () {
    test('AppSettings has synchronized access after init', () async {
      final languageCode = AppSettings.getLanguageCode();
      final themeMode = AppSettings.getThemeMode();

      expect(languageCode, isNotEmpty);
      expect(themeMode, isNotEmpty);
    });
  });

  group('Failure Handling', () {
    test('Failure message is readable', () {
      const failureMessage = 'Unable to load cards from database';
      final failure = Failure(failureMessage);

      expect(failure.message, failureMessage);
    });

    test('Multiple failures can be created with different messages', () {
      final failure1 = Failure('Error 1');
      final failure2 = Failure('Error 2');

      expect(failure1.message, isNot(failure2.message));
    });

    test('Failure message handles special characters', () {
      const failureMessage = 'Error: "Database" connection [failed]';
      final failure = Failure(failureMessage);

      expect(failure.message, failureMessage);
    });
  });

  group('Card Item Creation for Testing', () {
    test('CardItem with all fields can be created', () {
      final card = CardItem(
        id: 1,
        title: 'My Card',
        description: 'Card description',
        name: 'Code data',
        cardType: CardType.qrCode,
        sortOrder: 1,
        logoPath: null,
      );

      expect(card.id, 1);
      expect(card.title, 'My Card');
      expect(card.isQrCode, true);
    });

    test('CardItem with temp constructor can be created', () {
      final card = CardItem.temp(
        title: 'Temp Card',
        description: 'Temporary card',
        name: 'Temp code data',
        cardType: CardType.barcode,
        logoPath: null,
      );

      expect(card.id, isNull);
      expect(card.title, 'Temp Card');
      expect(card.isBarcode, true);
    });

    test('CardItem with null logoPath can be created', () {
      final card = CardItem(
        id: 1,
        title: 'My Card',
        description: 'Description',
        name: 'Code data',
        cardType: CardType.qrCode,
        sortOrder: 1,
        logoPath: null,
      );

      expect(card.logoPath, isNull);
    });
  });
}
