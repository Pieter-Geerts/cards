import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple unit tests for the code value bugfix.
/// These test only the model layer to ensure fast execution.
void main() {
  group('Code Value Bugfix - Model Tests', () {
    test('CardItem copyWith correctly updates code value', () {
      final originalCard = CardItem(
        id: 1,
        title: 'Test Card',
        description: 'Test Description',
        name: 'ORIGINAL_CODE',
        cardType: CardType.qrCode,
        sortOrder: 0,
        logoPath: null,
      );

      final updatedCard = originalCard.copyWith(name: 'NEW_CODE');

      expect(updatedCard.name, equals('NEW_CODE'));
      expect(updatedCard.title, equals('Test Card'));
      expect(updatedCard.description, equals('Test Description'));
      expect(updatedCard.cardType, equals(CardType.qrCode));
      expect(updatedCard.id, equals(1));
    });

    test('CardItem copyWith preserves all fields when updating code value', () {
      final originalCard = CardItem(
        id: 42,
        title: 'Complex Card',
        description: 'Complex Description with éñ chars',
        name: 'COMPLEX_CODE_123',
        cardType: CardType.barcode,
        sortOrder: 5,
        logoPath: 'assets/test_logo.svg',
      );

      final updatedCard = originalCard.copyWith(name: 'UPDATED_CODE_456');

      expect(updatedCard.name, equals('UPDATED_CODE_456'));
      expect(updatedCard.title, equals('Complex Card'));
      expect(
        updatedCard.description,
        equals('Complex Description with éñ chars'),
      );
      expect(updatedCard.cardType, equals(CardType.barcode));
      expect(updatedCard.logoPath, equals('assets/test_logo.svg'));
      expect(updatedCard.sortOrder, equals(5));
      expect(updatedCard.id, equals(42));
    });

    test(
      'CardItem copyWith can update multiple fields including code value',
      () {
        final originalCard = CardItem(
          id: 1,
          title: 'Original Title',
          description: 'Original Description',
          name: 'ORIGINAL_CODE',
          cardType: CardType.qrCode,
          sortOrder: 0,
          logoPath: null,
        );

        final updatedCard = originalCard.copyWith(
          title: 'New Title',
          description: 'New Description',
          name: 'NEW_CODE_VALUE',
          cardType: CardType.barcode,
          logoPath: 'new_logo.svg',
        );

        expect(updatedCard.name, equals('NEW_CODE_VALUE'));
        expect(updatedCard.title, equals('New Title'));
        expect(updatedCard.description, equals('New Description'));
        expect(updatedCard.cardType, equals(CardType.barcode));
        expect(updatedCard.logoPath, equals('new_logo.svg'));
        expect(updatedCard.id, equals(1)); // Should preserve ID
        expect(updatedCard.sortOrder, equals(0)); // Should preserve sortOrder
      },
    );

    test('CardItem name field (code value) is properly accessible', () {
      final card = CardItem(
        id: 1,
        title: 'Test Card',
        description: 'Test Description',
        name: 'TEST_QR_CODE_123',
        cardType: CardType.qrCode,
        sortOrder: 0,
        logoPath: null,
      );

      expect(card.name, equals('TEST_QR_CODE_123'));

      // Verify that the name field contains the code value
      expect(card.name.isNotEmpty, isTrue);
      expect(card.name.contains('TEST_QR_CODE'), isTrue);
    });

    test('CardItem supports different code value formats', () {
      // Test QR code format
      final qrCard = CardItem(
        id: 1,
        title: 'QR Card',
        description: 'QR Description',
        name: 'https://example.com/loyalty?user=123',
        cardType: CardType.qrCode,
        sortOrder: 0,
        logoPath: null,
      );

      expect(qrCard.name, equals('https://example.com/loyalty?user=123'));
      expect(qrCard.cardType, equals(CardType.qrCode));

      // Test barcode format
      final barcodeCard = CardItem(
        id: 2,
        title: 'Barcode Card',
        description: 'Barcode Description',
        name: '1234567890123',
        cardType: CardType.barcode,
        sortOrder: 0,
        logoPath: null,
      );

      expect(barcodeCard.name, equals('1234567890123'));
      expect(barcodeCard.cardType, equals(CardType.barcode));
    });
  });
}
