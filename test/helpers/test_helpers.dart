import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocks/platform_mocks.dart';

/// Set up shared preferences for testing
Future<void> setupSharedPreferences({Map<String, Object>? values}) async {
  SharedPreferences.setMockInitialValues(
    values ??
        {
          'language_code': 'nl', // Set Dutch as default for tests
          'theme_mode': 'system',
          'has_set_language': true,
        },
  );
}

/// Create a TestableWidget that wraps a widget with necessary providers
class TestableWidget extends StatelessWidget {
  final Widget child;
  final List<NavigatorObserver> navigatorObservers;

  const TestableWidget({
    required this.child,
    this.navigatorObservers = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('nl'), // Force Dutch locale for tests
      navigatorObservers: navigatorObservers,
      home: child,
    );
  }
}

/// Setup function to run before all tests
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PlatformMocks.setupAll();
  await setupSharedPreferences();
}

/// Generate a list of sample cards for testing
List<CardItem> generateSampleCards({int count = 3}) {
  return List.generate(
    count,
    (index) => CardItem(
      id: index + 1,
      title: 'Test Card ${index + 1}',
      description: 'Description ${index + 1}',
      name: 'CODE${index + 1}',
      cardType: index % 2 == 0 ? CardType.qrCode : CardType.barcode,
      sortOrder: index,
      createdAt: DateTime.now().subtract(Duration(days: index)),
    ),
  );
}

/// Verify text field properties
void verifyTextField(
  WidgetTester tester, {
  required String labelText,
  String? value,
  bool isRequired = false,
}) {
  final labelFinder = find.text(labelText);
  expect(labelFinder, findsOneWidget, reason: "Label '$labelText' not found");

  // Find the TextField associated with this label
  final textField = tester.widget<TextField>(
    find.ancestor(of: labelFinder, matching: find.byType(TextField)),
  );

  if (value != null) {
    expect(textField.controller?.text, value);
  }

  if (isRequired) {
    // This assumes your required fields have a validator
    expect(textField.decoration?.errorText, isNull);
  }
}
