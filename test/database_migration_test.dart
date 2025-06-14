import 'package:cards/helpers/database_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Migration Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Clear the database before each test
      await dbHelper.deleteAllCards();
    });

    tearDown(() async {
      await dbHelper.deleteAllCards();
    });

    test('should save and retrieve cards with new enum format', () async {
      // Create cards with new enum format
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
      final qrId = await dbHelper.insertCard(qrCard);
      final barcodeId = await dbHelper.insertCard(barcodeCard);

      // Retrieve cards
      final retrievedCards = await dbHelper.getCards();
      
      expect(retrievedCards.length, 2);
      
      final retrievedQr = retrievedCards.firstWhere((c) => c.id == qrId);
      final retrievedBarcode = retrievedCards.firstWhere((c) => c.id == barcodeId);

      expect(retrievedQr.cardType, CardType.qrCode);
      expect(retrievedQr.title, 'QR Test Card');
      expect(retrievedQr.name, 'QR123');

      expect(retrievedBarcode.cardType, CardType.barcode);
      expect(retrievedBarcode.title, 'Barcode Test Card');
      expect(retrievedBarcode.name, 'BC123');
    });

    test('should handle legacy data format during migration', () async {
      // Simulate legacy data by directly inserting old format
      final db = await dbHelper.database;
      
      // Insert card with legacy format
      await db.insert('cards', {
        'title': 'Legacy QR Card',
        'description': 'Legacy Description',
        'name': 'LEGACY123',
        'cardType': 'QR_CODE', // Legacy format
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'sortOrder': 0,
      });

      await db.insert('cards', {
        'title': 'Legacy Barcode Card',
        'description': 'Legacy Description',
        'name': 'LEGACY456',
        'cardType': 'BARCODE', // Legacy format
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'sortOrder': 1,
      });

      // Retrieve using the helper (should convert legacy format)
      final cards = await dbHelper.getCards();
      
      expect(cards.length, 2);
      
      final qrCard = cards.firstWhere((c) => c.name == 'LEGACY123');
      final barcodeCard = cards.firstWhere((c) => c.name == 'LEGACY456');

      // Should be converted to new enum format
      expect(qrCard.cardType, CardType.qrCode);
      expect(qrCard.title, 'Legacy QR Card');

      expect(barcodeCard.cardType, CardType.barcode);
      expect(barcodeCard.title, 'Legacy Barcode Card');
    });

    test('should handle invalid legacy data gracefully', () async {
      final db = await dbHelper.database;
      
      // Insert card with invalid legacy format
      await db.insert('cards', {
        'title': 'Invalid Card',
        'description': 'Invalid Type',
        'name': 'INVALID123',
        'cardType': 'INVALID_TYPE', // Invalid legacy format
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'sortOrder': 0,
      });

      // Retrieve using the helper
      final cards = await dbHelper.getCards();
      
      expect(cards.length, 1);
      
      final card = cards.first;
      
      // Should fallback to default (QR code)
      expect(card.cardType, CardType.qrCode);
      expect(card.title, 'Invalid Card');
    });

    test('should handle null cardType gracefully', () async {
      final db = await dbHelper.database;
      
      // Insert card with null cardType
      await db.insert('cards', {
        'title': 'Null Type Card',
        'description': 'No Type',
        'name': 'NULL123',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'sortOrder': 0,
        // Note: cardType is intentionally omitted (null)
      });

      // Retrieve using the helper
      final cards = await dbHelper.getCards();
      
      expect(cards.length, 1);
      
      final card = cards.first;
      
      // Should fallback to default (QR code)
      expect(card.cardType, CardType.qrCode);
      expect(card.title, 'Null Type Card');
    });

    test('should update cards with new enum format', () async {
      // Create and save a card
      final originalCard = CardItem(
        title: 'Update Test Card',
        description: 'Original Description',
        name: 'UPDATE123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      final cardId = await dbHelper.insertCard(originalCard);
      
      // Update the card with new type
      final updatedCard = originalCard.copyWith(
        id: cardId,
        cardType: CardType.barcode,
        description: 'Updated Description',
      );

      await dbHelper.updateCard(updatedCard);
      
      // Retrieve and verify
      final retrievedCard = await dbHelper.getCard(cardId);
      
      expect(retrievedCard, isNotNull);
      expect(retrievedCard!.cardType, CardType.barcode);
      expect(retrievedCard.description, 'Updated Description');
      expect(retrievedCard.title, 'Update Test Card'); // Unchanged
    });

    test('should maintain database integrity across operations', () async {
      // Create multiple cards of different types
      final cards = [
        CardItem(
          title: 'QR Card 1',
          description: 'QR Description 1',
          name: 'QR001',
          cardType: CardType.qrCode,
          sortOrder: 0,
        ),
        CardItem(
          title: 'Barcode Card 1',
          description: 'Barcode Description 1',
          name: 'BC001',
          cardType: CardType.barcode,
          sortOrder: 1,
        ),
        CardItem(
          title: 'QR Card 2',
          description: 'QR Description 2',
          name: 'QR002',
          cardType: CardType.qrCode,
          sortOrder: 2,
        ),
      ];

      // Save all cards
      final cardIds = <int>[];
      for (final card in cards) {
        final id = await dbHelper.insertCard(card);
        cardIds.add(id);
      }

      // Retrieve all cards
      final retrievedCards = await dbHelper.getCards();
      expect(retrievedCards.length, 3);

      // Verify types are preserved
      final qrCards = retrievedCards.where((c) => c.cardType == CardType.qrCode).toList();
      final barcodeCards = retrievedCards.where((c) => c.cardType == CardType.barcode).toList();

      expect(qrCards.length, 2);
      expect(barcodeCards.length, 1);

      // Delete one card
      await dbHelper.deleteCard(cardIds[1]); // Delete barcode card

      // Verify deletion
      final remainingCards = await dbHelper.getCards();
      expect(remainingCards.length, 2);
      expect(remainingCards.every((c) => c.cardType == CardType.qrCode), true);
    });
  });
}
