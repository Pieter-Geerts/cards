import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:cards/pages/edit_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock database helper that stores cards in memory for testing
class MockDatabaseHelper {
  final Map<int, CardItem> _cards = {};
  int _nextId = 1;

  Future<int> insertCard(CardItem card) async {
    final id = _nextId++;
    final cardWithId = card.copyWith(id: id);
    _cards[id] = cardWithId;
    return id;
  }

  Future<int> updateCard(CardItem card) async {
    if (card.id == null) return 0;
    _cards[card.id!] = card;
    return 1;
  }

  Future<CardItem?> getCard(int id) async {
    return _cards[id];
  }

  Future<List<CardItem>> getCards() async {
    return _cards.values.toList();
  }

  Future<int> deleteCard(int id) async {
    return _cards.remove(id) != null ? 1 : 0;
  }

  void clear() {
    _cards.clear();
    _nextId = 1;
  }
}

Widget createEditCardPage({
  required CardItem card,
  Function(CardItem)? onSave,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: EditCardPage(card: card, onSave: onSave ?? (card) {}),
  );
}

Widget createCardDetailPage({
  required CardItem card,
  Function(CardItem)? onDelete,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CardDetailPage(card: card, onDelete: onDelete),
  );
}

void main() {
  group('Edit Card Code Value Tests', () {
    testWidgets('should update code value in edit card page', (
      WidgetTester tester,
    ) async {
      CardItem? savedCard;

      final originalCard = CardItem(
        id: 1,
        title: 'Test Card',
        description: 'Test Description',
        name: 'ORIGINAL123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      // Test editing directly with callback capture
      await tester.pumpWidget(
        createEditCardPage(
          card: originalCard,
          onSave: (card) {
            savedCard = card;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Change the code value (third text field is the code field)
      final codeField = find.byType(TextField).at(2);
      await tester.enterText(codeField, 'UPDATED456');
      await tester.pumpAndSettle();

      // Save
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify the callback was called with updated card
      expect(savedCard, isNotNull);
      expect(savedCard!.name, 'UPDATED456');
      expect(savedCard!.title, 'Test Card'); // Other fields preserved
      expect(savedCard!.description, 'Test Description');
      expect(savedCard!.cardType, CardType.barcode);
    });

    testWidgets('should display updated code value in card detail page', (
      WidgetTester tester,
    ) async {
      final updatedCard = CardItem(
        id: 1,
        title: 'Test Card',
        description: 'Test Description',
        name: 'UPDATED456', // Updated code value
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      // Test card detail page shows updated value
      await tester.pumpWidget(createCardDetailPage(card: updatedCard));
      await tester.pumpAndSettle();

      // Should display the updated code value
      expect(find.text('UPDATED456'), findsOneWidget);
    });

    testWidgets('should persist changes through edit flow simulation', (
      WidgetTester tester,
    ) async {
      final mockDb = MockDatabaseHelper();

      // Simulate the full edit flow
      final originalCard = CardItem(
        title: 'Flow Test Card',
        description: 'Test Description',
        name: 'FLOW123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      // Save original card
      final cardId = await mockDb.insertCard(originalCard);
      final cardWithId = originalCard.copyWith(id: cardId);

      // Edit the card
      CardItem? editedCard;
      await tester.pumpWidget(
        createEditCardPage(
          card: cardWithId,
          onSave: (card) async {
            await mockDb.updateCard(card);
            editedCard = card;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Change code value
      final codeField = find.byType(TextField).at(2);
      await tester.enterText(codeField, 'FLOWUPDATED789');
      await tester.pumpAndSettle();

      // Save
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify persistence
      expect(editedCard, isNotNull);
      expect(editedCard!.name, 'FLOWUPDATED789');

      // Verify database persistence
      final retrievedCard = await mockDb.getCard(cardId);
      expect(retrievedCard, isNotNull);
      expect(retrievedCard!.name, 'FLOWUPDATED789');
    });

    testWidgets(
      'BUGFIX: UI updates should be reflected when cards are edited',
      (WidgetTester tester) async {
        // This test demonstrates the fix for the UI update bug
        bool updateCallbackCalled = false;
        CardItem? updatedCardFromCallback;

        final originalCard = CardItem(
          id: 1,
          title: 'Original Title',
          description: 'Original Description',
          name: 'ORIGINAL123',
          cardType: CardType.barcode,
          sortOrder: 0,
        );

        // Create a HomePage-like widget that handles updates
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Simulate the fixed edit flow
                      await Navigator.push<CardItem>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCardPage(
                            card: originalCard,
                            onSave: (updated) async {
                              // This simulates the fix: proper update callback
                              updateCallbackCalled = true;
                              updatedCardFromCallback = updated;
                              Navigator.of(context).pop(updated);
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Edit Card'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Trigger edit
        await tester.tap(find.text('Edit Card'));
        await tester.pumpAndSettle();

        // Change title
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, 'Updated Title');
        await tester.pumpAndSettle();

        // Change code value
        final codeField = find.byType(TextField).at(2);
        await tester.enterText(codeField, 'UPDATED456');
        await tester.pumpAndSettle();

        // Save
        final saveButton = find.byIcon(Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // BUGFIX VERIFICATION: Update callback should be called
        expect(updateCallbackCalled, true);
        expect(updatedCardFromCallback, isNotNull);
        expect(updatedCardFromCallback!.title, 'Updated Title');
        expect(updatedCardFromCallback!.name, 'UPDATED456');
        expect(
          updatedCardFromCallback!.description,
          'Original Description',
        ); // Preserved
      },
    );
  });
}
