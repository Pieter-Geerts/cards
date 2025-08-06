import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_database_helper.dart';

void main() {
  group('DatabaseHelper Unit Tests (Fast)', () {
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
    });

    test('should insert and retrieve cards', () async {
      // Arrange
      final card = CardItem(
        title: 'Test Card',
        description: 'Test Description',
        name: 'Test Name',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      // Act
      final id = await mockDb.insertCard(card);
      final cards = await mockDb.getCards();

      // Assert
      expect(id, 1);
      expect(cards, hasLength(1));
      expect(cards.first.title, 'Test Card');
      expect(cards.first.description, 'Test Description');
      expect(cards.first.name, 'Test Name');
      expect(cards.first.id, 1);
    });

    test('should update a card', () async {
      // Arrange
      final card = CardItem(
        title: 'Original Title',
        description: 'Original Description',
        name: 'Original Name',
        cardType: CardType.barcode,
        sortOrder: 0,
      );
      final id = await mockDb.insertCard(card);

      // Act
      final updatedCard = card.copyWith(
        id: id,
        title: 'Updated Title',
        description: 'Updated Description',
      );
      final rowsAffected = await mockDb.updateCard(updatedCard);

      // Assert
      expect(rowsAffected, 1);
      final cards = await mockDb.getCards();
      expect(cards.first.title, 'Updated Title');
      expect(cards.first.description, 'Updated Description');
      expect(cards.first.name, 'Original Name'); // Unchanged
    });

    test('should delete a card', () async {
      // Arrange
      final card = CardItem(
        title: 'Card to Delete',
        description: 'Description to Delete',
        name: 'Name to Delete',
        cardType: CardType.qrCode,
        sortOrder: 1,
      );
      final id = await mockDb.insertCard(card);

      // Act
      final rowsDeleted = await mockDb.deleteCard(id);

      // Assert
      expect(rowsDeleted, 1);
      final cards = await mockDb.getCards();
      expect(cards, isEmpty);
    });

    test('should get next sort order', () async {
      // Arrange - empty database
      expect(await mockDb.getNextSortOrder(), 0);

      // Add cards with different sort orders
      await mockDb.insertCard(
        CardItem(
          title: 'Card 1',
          description: '',
          name: 'card1',
          cardType: CardType.qrCode,
          sortOrder: 5,
        ),
      );

      await mockDb.insertCard(
        CardItem(
          title: 'Card 2',
          description: '',
          name: 'card2',
          cardType: CardType.qrCode,
          sortOrder: 10,
        ),
      );

      // Act & Assert
      expect(await mockDb.getNextSortOrder(), 11);
    });

    test('should sort cards by sortOrder', () async {
      // Arrange - insert cards in reverse order
      await mockDb.insertCard(
        CardItem(
          title: 'Card C',
          description: '',
          name: 'cardC',
          cardType: CardType.qrCode,
          sortOrder: 30,
        ),
      );

      await mockDb.insertCard(
        CardItem(
          title: 'Card A',
          description: '',
          name: 'cardA',
          cardType: CardType.qrCode,
          sortOrder: 10,
        ),
      );

      await mockDb.insertCard(
        CardItem(
          title: 'Card B',
          description: '',
          name: 'cardB',
          cardType: CardType.qrCode,
          sortOrder: 20,
        ),
      );

      // Act
      final cards = await mockDb.getCards();

      // Assert - should be sorted by sortOrder
      expect(cards, hasLength(3));
      expect(cards[0].title, 'Card A');
      expect(cards[1].title, 'Card B');
      expect(cards[2].title, 'Card C');
    });

    test('should clear all data with reset', () async {
      // Arrange
      await mockDb.insertCard(
        CardItem(
          title: 'Test Card 1',
          description: '',
          name: 'test1',
          cardType: CardType.qrCode,
          sortOrder: 0,
        ),
      );
      await mockDb.insertCard(
        CardItem(
          title: 'Test Card 2',
          description: '',
          name: 'test2',
          cardType: CardType.qrCode,
          sortOrder: 1,
        ),
      );

      // Act
      mockDb.reset();

      // Assert
      final cards = await mockDb.getCards();
      expect(cards, isEmpty);
      expect(await mockDb.getNextSortOrder(), 0);
    });
  });
}
