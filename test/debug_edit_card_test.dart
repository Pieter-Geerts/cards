import 'package:cards/helpers/database_helper.dart';
import 'package:cards/main.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/edit_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Edit Card Debug Test', () {
    testWidgets('debug the exact edit flow with detailed logging', (
      WidgetTester tester,
    ) async {
      // Clear any existing data
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteAllCards();

      // Create a test card
      final testCard = CardItem(
        title: 'Debug Card',
        description: 'Original description',
        name: 'DEBUG123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      await dbHelper.insertCard(testCard);
      print('DEBUG: Inserted test card with title: ${testCard.title}');

      // Start the main app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      print('DEBUG: App loaded');

      // Verify the original card is displayed
      expect(find.text('Debug Card'), findsOneWidget);
      print('DEBUG: Original card found on home page');

      // Find the three dots menu (more options)
      final cardWidget = find.text('Debug Card').first;

      // Look for the card's menu button - it should be a GestureDetector with three dots icon
      final menuButton = find.descendant(
        of: find.ancestor(of: cardWidget, matching: find.byType(Card)),
        matching: find.byIcon(Icons.more_vert),
      );

      print('DEBUG: Looking for menu button...');
      expect(menuButton, findsOneWidget);

      // Tap the menu button
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      print('DEBUG: Tapped menu button');

      // Find and tap the edit option (could be "Edit" or "Bewerken" depending on locale)
      Finder editFinder;
      if (find.text('Edit').evaluate().isNotEmpty) {
        editFinder = find.text('Edit');
      } else {
        editFinder = find.text('Bewerken');
      }

      expect(editFinder, findsOneWidget);
      await tester.tap(editFinder);
      await tester.pumpAndSettle();
      print('DEBUG: Tapped edit option');

      // Should be on edit page now
      expect(find.byType(EditCardPage), findsOneWidget);
      print('DEBUG: On edit page');

      // Find the title field and change it
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Updated Debug Card');
      await tester.pumpAndSettle();
      print('DEBUG: Updated title field');

      // Save the changes
      final saveButton = find.byIcon(Icons.save);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      print('DEBUG: Tapped save button');

      // Should be back on home page
      print('DEBUG: Back on home page, checking for updated title...');

      // The critical test - is the updated title showing?
      expect(find.text('Updated Debug Card'), findsOneWidget);
      expect(find.text('Debug Card'), findsNothing);

      print('DEBUG: Test completed - updated title should be visible');

      // Verify the card was actually updated in database
      final cards = await dbHelper.getCards();
      expect(cards.length, 1);
      expect(cards.first.title, 'Updated Debug Card');
      print('DEBUG: Database verification passed');

      // Clean up
      await dbHelper.deleteAllCards();
    });
  });
}
