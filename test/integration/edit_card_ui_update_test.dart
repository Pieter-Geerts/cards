import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:cards/pages/edit_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';
import '../mocks/mock_database_helper.dart';

/// Fast integration test using mocks instead of real SQLite database
/// This test runs in ~1-2 seconds instead of 45+ seconds
void main() {
  late MockDatabaseHelper mockDb;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockDb = MockDatabaseHelper();
  });

  group('Edit Card UI Update Integration Test - Fast Version', () {
    testWidgets('complete edit flow navigates correctly and saves data', (
      WidgetTester tester,
    ) async {
      // Arrange: Create test card in mock database
      final testCard = CardItem(
        id: 1,
        title: 'Test Card for Edit',
        description: 'Original description',
        name: 'ORIGINAL123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      await mockDb.insertCard(testCard);

      // Act: Start with CardDetailPage
      await tester.pumpWidget(
        TestableWidget(child: CardDetailPage(card: testCard, onDelete: (_) {})),
      );
      await tester.pumpAndSettle();

      // Verify original card data is displayed
      expect(find.text('Test Card for Edit'), findsOneWidget);

      // Navigate to edit page by tapping edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Should be on EditCardPage
      expect(find.byType(EditCardPage), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(3));

      // Update the title
      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Updated Test Card');
      await tester.pumpAndSettle();

      // Update the code value (typically the 3rd TextField)
      final codeField = find.byType(TextField).at(2);
      await tester.enterText(codeField, 'UPDATED456');
      await tester.pumpAndSettle();

      // Save the changes - this should trigger navigation back
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert: Should have navigated back to CardDetailPage
      expect(find.byType(CardDetailPage), findsOneWidget);

      // Verify data was persisted in mock database
      final cards = await mockDb.getCards();
      expect(cards.length, 1);
      expect(cards.first.title, 'Updated Test Card');
      expect(cards.first.name, 'UPDATED456');
      expect(cards.first.description, 'Original description'); // Preserved
    });

    testWidgets('EditCardPage alone saves changes correctly', (
      WidgetTester tester,
    ) async {
      // Arrange: Create card for standalone edit test
      final testCard = CardItem(
        id: 2,
        title: 'Standalone Edit Test',
        description: 'Test description',
        name: 'STANDALONE123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      CardItem? savedCard;

      // Act: Test EditCardPage in isolation
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
      await tester.enterText(titleField, 'Modified Standalone Title');
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Assert: Callback should receive updated card
      expect(savedCard, isNotNull);
      expect(savedCard!.title, 'Modified Standalone Title');
      expect(savedCard!.description, 'Test description'); // Preserved
      expect(savedCard!.name, 'STANDALONE123'); // Preserved
      expect(savedCard!.cardType, CardType.qrCode); // Preserved
    });
  });
}
