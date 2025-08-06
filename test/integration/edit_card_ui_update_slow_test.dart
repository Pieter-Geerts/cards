import 'package:cards/helpers/database_helper.dart';
import 'package:cards/main.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// This is a slow integration test that uses the real app and database.
/// It provides end-to-end testing but takes several minutes to complete.
///
/// Run this test specifically with: flutter test --tags=slow
/// Skip in regular runs with: flutter test --exclude-tags=slow
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Edit Card UI Update - Real App Integration Test', () {
    testWidgets(
      'editing a card should update the UI in real app flow',
      (WidgetTester tester) async {
        // Clear any existing data
        final dbHelper = DatabaseHelper();
        await dbHelper.deleteAllCards();

        // Create a test card
        final testCard = CardItem(
          title: 'Test Card for Edit',
          description: 'Original description',
          name: 'ORIGINAL123',
          cardType: CardType.barcode,
          sortOrder: 0,
        );

        await dbHelper.insertCard(testCard);

        // Start the main app
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Verify the original card is displayed
        expect(find.text('Test Card for Edit'), findsOneWidget);

        // Find and tap the card to open options
        final cardTile = find.text('Test Card for Edit');
        await tester.longPress(cardTile);
        await tester.pumpAndSettle();

        // Tap edit option
        expect(find.text('Edit'), findsOneWidget);
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Should be on edit page now
        expect(find.byType(TextField), findsAtLeastNWidgets(3));

        // Change the title
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, 'Updated Test Card');
        await tester.pumpAndSettle();

        // Change the code value
        final codeField = find.byType(TextField).at(2);
        await tester.enterText(codeField, 'UPDATED456');
        await tester.pumpAndSettle();

        // Save the changes
        final saveButton = find.byIcon(Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.text('Updated Test Card'), findsOneWidget);
        expect(find.text('Test Card for Edit'), findsNothing);

        // Verify the card was actually updated in database
        final cards = await dbHelper.getCards();
        expect(cards.length, 1);
        expect(cards.first.title, 'Updated Test Card');
        expect(cards.first.name, 'UPDATED456');
        expect(cards.first.description, 'Original description');

        // Clean up
        await dbHelper.deleteAllCards();
      },
      tags: ['integration', 'slow', 'e2e'],
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });
}
