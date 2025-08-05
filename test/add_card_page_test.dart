import 'package:cards/models/card_item.dart';
import 'package:cards/pages/add_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'helpers/test_helpers.dart';
import 'mocks/generate_mocks.mocks.dart';

void main() {
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
  });

  testWidgets('AddCardPage renders form with empty fields', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: const AddCardPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Voeg Kaart Toe'), findsOneWidget); // AppBar title
    expect(find.byType(TextField), findsWidgets); // Input fields
    expect(
      find.byType(DropdownButton<CardType>),
      findsOneWidget,
    ); // Card type selector
    expect(find.byIcon(Icons.check), findsOneWidget); // Save button
  });

  testWidgets('AddCardPage allows filling form and saving', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: const AddCardPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Act - fill the form
    await tester.enterText(
      find.widgetWithText(TextField, 'Naam van de winkel of service'),
      'Test Card Title',
    );
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Extra details (bijv. lidmaatschapsnummer)',
      ),
      'Test Description',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'De code voor de QR/Barcode'),
      '12345678',
    );

    // Save the card
    await tester.tap(find.widgetWithText(ElevatedButton, 'Opslaan'));
    await tester.pumpAndSettle();

    // Assert - should have popped with a card
    verify(mockNavigatorObserver.didPop(any, any));
  });

  testWidgets('AddCardPage renders with code visualization', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: const AddCardPage(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the page renders with a code visualization
    expect(find.text('Code Voorbeeld'), findsOneWidget);
    
    // Verify the main form elements are present
    expect(find.byType(TextField), findsAtLeastNWidgets(3));
    expect(find.text('Opslaan'), findsOneWidget);
  });
}
