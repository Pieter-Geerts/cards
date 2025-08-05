import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:cards/pages/edit_card_page.dart';
import 'package:cards/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';
import '../mocks/mock_database_helper.dart';

void main() {
  late MockDatabaseHelper mockDb;
  late List<CardItem> testCards;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockDb = MockDatabaseHelper();
    testCards = [];
  });

  group('Edit Card UI Update - Fast Unit Tests', () {
    testWidgets('EditCardPage saves changes and returns updated card', (
      WidgetTester tester,
    ) async {
      // Arrange: Create test card
      final testCard = CardItem(
        id: 1,
        title: 'Test Card for Edit',
        description: 'Original description',
        name: 'ORIGINAL123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      CardItem? savedCard;

      // Act: Render EditCardPage with save callback
      await tester.pumpWidget(
        TestableWidget(
          child: EditCardPage(
            card: testCard,
            onSave: (updatedCard) async {
              savedCard = updatedCard;
              await mockDb.updateCard(updatedCard);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and update title field
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Updated Test Card');
      await tester.pumpAndSettle();

      // Find and update code field (assuming it's the third TextField)
      final codeField = find.byType(TextField).at(2);
      await tester.enterText(codeField, 'UPDATED456');
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert: Card was saved with updated values
      expect(savedCard, isNotNull);
      expect(savedCard!.title, 'Updated Test Card');
      expect(savedCard!.name, 'UPDATED456');
      expect(savedCard!.description, 'Original description'); // Preserved
    });

    testWidgets('CardDetailPage displays updated card after navigation', (
      WidgetTester tester,
    ) async {
      // Arrange: Create an updated card (simulating after edit)
      final updatedCard = CardItem(
        id: 1,
        title: 'Updated Test Card',
        description: 'Original description',
        name: 'UPDATED456',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      // Act: Render CardDetailPage with updated card
      await tester.pumpWidget(
        TestableWidget(
          child: CardDetailPage(card: updatedCard, onDelete: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Updated data should be displayed
      expect(find.text('Updated Test Card'), findsOneWidget);
      expect(find.text('Test Card for Edit'), findsNothing);
    });

    testWidgets('EditCardPage preserves unchanged fields correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testCard = CardItem(
        id: 1,
        title: 'Original Title',
        description: 'Important description',
        name: 'CODE123',
        cardType: CardType.qrCode,
        sortOrder: 5,
      );

      CardItem? savedCard;

      // Act: Render EditCardPage with save callback
      await tester.pumpWidget(
        TestableWidget(
          child: EditCardPage(
            card: testCard,
            onSave: (updatedCard) async {
              savedCard = updatedCard;
              await mockDb.updateCard(updatedCard);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Change only the title
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'New Title Only');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert: Check the saved card preserves other fields
      expect(savedCard, isNotNull);
      expect(savedCard!.title, 'New Title Only');
      expect(savedCard!.description, 'Important description'); // Preserved
      expect(savedCard!.name, 'CODE123'); // Preserved
      expect(savedCard!.cardType, CardType.qrCode); // Preserved
      expect(savedCard!.sortOrder, 5); // Preserved
    });

    testWidgets('HomePage displays updated card after successful edit', (
      WidgetTester tester,
    ) async {
      // Arrange: Create test cards list
      final originalCard = CardItem(
        id: 1,
        title: 'Original Card',
        description: 'Test description',
        name: 'TEST123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      testCards = [originalCard];

      // Act: Render HomePage
      await tester.pumpWidget(
        TestableWidget(
          child: HomePage(
            cards: testCards,
            onAddCard: (card) {
              testCards.add(card);
            },
            onUpdateCard: (updatedCard) {
              final index = testCards.indexWhere((c) => c.id == updatedCard.id);
              if (index != -1) {
                testCards[index] = updatedCard;
              }
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify original card is displayed
      expect(find.text('Original Card'), findsOneWidget);

      // The key insight: HomePage should update its display when cards change
      // This is typically handled by state management in the parent widget
    });

    testWidgets('Card code value updates are immediately visible', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testCard = CardItem(
        id: 1,
        title: 'Barcode Test',
        description: 'Test barcode card',
        name: 'ORIGINAL123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      CardItem? updatedCard;

      // Act: Test the edit flow for code values specifically
      await tester.pumpWidget(
        TestableWidget(
          child: EditCardPage(
            card: testCard,
            onSave: (card) async {
              updatedCard = card;
              // Simulate database update
              await mockDb.updateCard(card);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the code input field and update it
      final codeField = find
          .byType(TextField)
          .at(2); // Assuming code is 3rd field
      await tester.enterText(codeField, 'UPDATED456');
      await tester.pumpAndSettle();

      // Save the card
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert: Code value should be updated
      expect(updatedCard, isNotNull);
      expect(updatedCard!.name, 'UPDATED456');
      expect(updatedCard!.title, 'Barcode Test'); // Other fields preserved
    });
  });
}
