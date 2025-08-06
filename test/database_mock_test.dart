import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/mock_card_repository.dart';

void main() {
  group('Card Repository Tests', () {
    late MockCardRepository cardRepository;

    setUp(() {
      cardRepository = MockCardRepository();
    });

    test('should save and retrieve cards with enum format', () async {
      // Create cards with enum format
      final qrCard = CardItem(
        title: 'QR Test Card',
        description: 'Test QR Card',
        name: 'QR123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      final barcodeCard = CardItem(
        title: 'Barcode Test Card',
        description: 'Test Barcode Card',
        name: 'BC123',
        cardType: CardType.barcode,
        sortOrder: 1,
      );

      // Save cards
      final qrId = await cardRepository.insertCard(qrCard);
      final barcodeId = await cardRepository.insertCard(barcodeCard);

      // Retrieve cards
      final retrievedCards = await cardRepository.getCards();

      expect(retrievedCards.length, 2);

      // Find the cards by their IDs (should be 1 and 2)
      final retrievedQrCard = retrievedCards.firstWhere((c) => c.id == qrId);
      final retrievedBarcodeCard = retrievedCards.firstWhere(
        (c) => c.id == barcodeId,
      );

      // Verify the QR card
      expect(retrievedQrCard.title, 'QR Test Card');
      expect(retrievedQrCard.cardType, CardType.qrCode);

      // Verify the barcode card
      expect(retrievedBarcodeCard.title, 'Barcode Test Card');
      expect(retrievedBarcodeCard.cardType, CardType.barcode);
    });

    test('should update cards correctly', () async {
      // Create a card
      final card = CardItem(
        title: 'Original Title',
        description: 'Original Description',
        name: 'Original Name',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      // Save the card
      final id = await cardRepository.insertCard(card);

      // Update the card
      final updatedCard = CardItem(
        id: id,
        title: 'Updated Title',
        description: 'Updated Description',
        name: 'Updated Name',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      await cardRepository.updateCard(updatedCard);

      // Retrieve the updated card
      final retrievedCard = await cardRepository.getCard(id);

      expect(retrievedCard?.title, 'Updated Title');
      expect(retrievedCard?.description, 'Updated Description');
      expect(retrievedCard?.name, 'Updated Name');
    });

    test('should delete cards correctly', () async {
      // Create a card
      final card = CardItem(
        title: 'Card to Delete',
        description: 'This card will be deleted',
        name: 'Delete Me',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      // Save the card
      final id = await cardRepository.insertCard(card);

      // Verify the card exists
      var retrievedCards = await cardRepository.getCards();
      expect(retrievedCards.length, 1);

      // Delete the card
      await cardRepository.deleteCard(id);

      // Verify the card no longer exists
      retrievedCards = await cardRepository.getCards();
      expect(retrievedCards.length, 0);
    });

    test('should reorder cards correctly', () async {
      // Create test cards
      final cards = await cardRepository.populateWithTestData();
      expect(cards.length, 3);

      // Original order should be 0, 1, 2
      expect(cards[0].sortOrder, 0);
      expect(cards[1].sortOrder, 1);
      expect(cards[2].sortOrder, 2);

      // Reorder the cards
      final reorderedCards = List<CardItem>.from(cards);

      // Move the last card to the first position
      final lastCard = reorderedCards.removeAt(2);
      reorderedCards.insert(0, lastCard.copyWith(sortOrder: 0));

      // Update sort orders for remaining cards
      for (int i = 1; i < reorderedCards.length; i++) {
        reorderedCards[i] = reorderedCards[i].copyWith(sortOrder: i);
      }

      // Save the new order
      await cardRepository.reorderCards(reorderedCards);

      // Verify new order
      final updatedCards = await cardRepository.getCards();
      expect(updatedCards[0].title, 'Loyalty Card');
      expect(updatedCards[0].sortOrder, 0);
      expect(updatedCards[1].title, 'Test QR Card');
      expect(updatedCards[1].sortOrder, 1);
      expect(updatedCards[2].title, 'Test Barcode Card');
      expect(updatedCards[2].sortOrder, 2);
    });
  });
}
