import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/platform_mocks.dart';

/// Set up shared preferences for testing with comprehensive defaults
Future<void> setupSharedPreferences({Map<String, Object>? values}) async {
  SharedPreferences.setMockInitialValues(
    values ??
        {
          'language_code': 'nl', // Set Dutch as default for tests
          'theme_mode': 'system',
          'has_set_language': true,
          // Add performance-related settings
          'cache_enabled': true,
          'max_cache_size': 1000,
          'preload_logos': true,
        },
  );
}

/// Create a TestableWidget that wraps a widget with necessary providers
/// Enhanced with performance optimizations
class TestableWidget extends StatelessWidget {
  final Widget child;
  final List<NavigatorObserver> navigatorObservers;
  final Locale? locale;

  const TestableWidget({
    required this.child,
    this.navigatorObservers = const [],
    this.locale,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? const Locale('nl'), // Force Dutch locale for tests
      navigatorObservers: navigatorObservers,
      // Performance optimizations for tests
      debugShowCheckedModeBanner: false,
      home: child,
      // Add theme for consistent testing
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

/// Setup function to run before all tests with enhanced configuration
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PlatformMocks.setupAll();
  await setupSharedPreferences();
}

/// Generate a list of sample cards for testing with realistic data
List<CardItem> generateSampleCards({int count = 3}) {
  final cardTypes = [CardType.qrCode, CardType.barcode];
  final sampleTitles = [
    'Starbucks',
    'Albert Heijn',
    'Netflix',
    'Spotify',
    'Apple Store',
  ];
  final sampleDescriptions = [
    'Coffee loyalty card',
    'Grocery store card',
    'Streaming service',
    'Music streaming',
    'Technology store',
  ];

  return List.generate(
    count,
    (index) => CardItem(
      id: index + 1,
      title: sampleTitles[index % sampleTitles.length],
      description: sampleDescriptions[index % sampleDescriptions.length],
      name: 'CODE${index + 1}${String.fromCharCode(65 + index)}',
      cardType: cardTypes[index % cardTypes.length],
      sortOrder: index,
      createdAt: DateTime.now().subtract(Duration(days: index)),
      logoPath: index % 3 == 0 ? 'assets/icons/sample_logo_$index.png' : null,
    ),
  );
}

/// Verify text field properties with enhanced validation
void verifyTextField(
  WidgetTester tester, {
  required String labelText,
  String? value,
  bool isRequired = false,
  bool enabled = true,
}) {
  final labelFinder = find.text(labelText);
  expect(
    labelFinder,
    findsOneWidget,
    reason: 'Label "$labelText" should be present',
  );

  if (value != null) {
    final valueFinder = find.text(value);
    expect(
      valueFinder,
      findsOneWidget,
      reason: 'Value "$value" should be present',
    );
  }

  // Verify field is enabled/disabled as expected
  final textField = tester.widget<TextField>(find.byType(TextField).first);
  expect(
    textField.enabled,
    equals(enabled),
    reason: 'TextField enabled state should be $enabled',
  );
}

/// Helper to wait for animations and stabilize UI
Future<void> stabilizeUI(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  // Additional pump for complex animations
  await tester.pump(const Duration(milliseconds: 50));
}

/// Create a performance-optimized card for testing
CardItem createTestCard({
  int? id,
  String title = 'Test Card',
  String description = 'Test Description',
  String name = 'TEST123',
  CardType cardType = CardType.qrCode,
  int sortOrder = 0,
  String? logoPath,
}) {
  return CardItem(
    id: id,
    title: title,
    description: description,
    name: name,
    cardType: cardType,
    sortOrder: sortOrder,
    createdAt: DateTime.now(),
    logoPath: logoPath,
  );
}

/// Test performance measurements
class TestPerformance {
  static final Stopwatch _stopwatch = Stopwatch();

  static void start() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  static int stop() {
    _stopwatch.stop();
    return _stopwatch.elapsedMilliseconds;
  }

  static void expectFastExecution(int maxMs, String operation) {
    final elapsed = stop();
    expect(
      elapsed,
      lessThan(maxMs),
      reason:
          '$operation should complete in under ${maxMs}ms but took ${elapsed}ms',
    );
  }
}

/// Mock data generators for different test scenarios
class TestDataGenerators {
  static List<CardItem> emptyCardList() => [];

  static List<CardItem> singleCard() => [createTestCard()];

  static List<CardItem> manyCards({int count = 50}) =>
      generateSampleCards(count: count);

  static List<CardItem> cardsWithMixedTypes() => [
    createTestCard(id: 1, cardType: CardType.qrCode),
    createTestCard(id: 2, cardType: CardType.barcode),
    createTestCard(id: 3, cardType: CardType.qrCode),
  ];

  static List<CardItem> cardsWithLongTitles() => [
    createTestCard(
      title:
          'This is a very long title that should test text wrapping and overflow handling in the UI components',
      description:
          'This is also a very long description that tests how the UI handles large amounts of text content',
    ),
  ];
}
