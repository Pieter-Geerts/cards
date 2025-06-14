import 'package:cards/models/card_item.dart';
import 'package:cards/models/code_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardType enum', () {
    test('should have correct display names', () {
      expect(CardType.qrCode.displayName, 'QR Code');
      expect(CardType.barcode.displayName, 'Barcode');
    });

    test('should correctly identify 2D codes', () {
      expect(CardType.qrCode.is2D, true);
      expect(CardType.barcode.is2D, false);
    });

    test('should correctly identify 1D codes', () {
      expect(CardType.qrCode.is1D, false);
      expect(CardType.barcode.is1D, true);
    });

    test('should convert legacy values correctly', () {
      expect(CardTypeExtension.fromLegacyValue('QR_CODE'), CardType.qrCode);
      expect(CardTypeExtension.fromLegacyValue('BARCODE'), CardType.barcode);
      expect(CardTypeExtension.fromLegacyValue('qr_code'), CardType.qrCode);
      expect(CardTypeExtension.fromLegacyValue('barcode'), CardType.barcode);
      expect(CardTypeExtension.fromLegacyValue('INVALID'), CardType.qrCode); // fallback
      expect(CardTypeExtension.fromLegacyValue(''), CardType.qrCode); // fallback
    });
  });

  group('CardItem', () {
    test('should create with default values', () {
      final card = CardItem(
        title: 'Test Card',
        description: 'Test Description',
        name: 'Test123',
        sortOrder: 0,
      );

      expect(card.title, 'Test Card');
      expect(card.description, 'Test Description');
      expect(card.name, 'Test123');
      expect(card.cardType, CardType.qrCode); // default
      expect(card.sortOrder, 0);
      expect(card.id, null);
      expect(card.logoPath, null);
    });

    test('should create with specified card type', () {
      final card = CardItem(
        title: 'Barcode Card',
        description: 'Test Barcode',
        name: 'ABC123',
        cardType: CardType.barcode,
        sortOrder: 1,
      );

      expect(card.cardType, CardType.barcode);
      expect(card.isBarcode, true);
      expect(card.isQrCode, false);
      expect(card.is1D, true);
      expect(card.is2D, false);
    });

    test('should create temp card correctly', () {
      final card = CardItem.temp(
        title: 'Temp Card',
        description: 'Temporary',
        name: 'TEMP123',
      );

      expect(card.title, 'Temp Card');
      expect(card.id, null);
      expect(card.sortOrder, -1);
      expect(card.cardType, CardType.qrCode); // default
    });

    test('should serialize to map correctly', () {
      final card = CardItem(
        id: 123,
        title: 'Test Card',
        description: 'Test Description',
        name: 'Test123',
        cardType: CardType.barcode,
        sortOrder: 0,
        logoPath: '/path/to/logo.png',
      );

      final map = card.toMap();

      expect(map['id'], 123);
      expect(map['title'], 'Test Card');
      expect(map['description'], 'Test Description');
      expect(map['name'], 'Test123');
      expect(map['cardType'], 'barcode'); // enum name
      expect(map['sortOrder'], 0);
      expect(map['logoPath'], '/path/to/logo.png');
      expect(map['createdAt'], isA<int>());
    });

    test('should deserialize from map with new enum format', () {
      final map = {
        'id': 456,
        'title': 'Saved Card',
        'description': 'From Database',
        'name': 'SAVED123',
        'cardType': 'barcode', // new enum format
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'sortOrder': 1,
        'logoPath': '/path/to/saved.png',
      };

      final card = CardItem.fromMap(map);

      expect(card.id, 456);
      expect(card.title, 'Saved Card');
      expect(card.description, 'From Database');
      expect(card.name, 'SAVED123');
      expect(card.cardType, CardType.barcode);
      expect(card.sortOrder, 1);
      expect(card.logoPath, '/path/to/saved.png');
    });

    test('should deserialize from map with legacy format', () {
      final map = {
        'id': 789,
        'title': 'Legacy Card',
        'description': 'Old Format',
        'name': 'LEGACY123',
        'cardType': 'QR_CODE', // legacy format
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'sortOrder': 2,
      };

      final card = CardItem.fromMap(map);

      expect(card.id, 789);
      expect(card.cardType, CardType.qrCode);
      expect(card.isQrCode, true);
    });

    test('should handle null cardType in map', () {
      final map = {
        'title': 'Null Type Card',
        'description': 'No Type',
        'name': 'NULL123',
        'sortOrder': 0,
      };

      final card = CardItem.fromMap(map);

      expect(card.cardType, CardType.qrCode); // default fallback
    });

    test('should handle invalid cardType in map', () {
      final map = {
        'title': 'Invalid Type Card',
        'description': 'Invalid Type',
        'name': 'INVALID123',
        'cardType': 'INVALID_TYPE',
        'sortOrder': 0,
      };

      final card = CardItem.fromMap(map);

      expect(card.cardType, CardType.qrCode); // fallback for invalid legacy
    });

    test('should copy with new values', () {
      final original = CardItem(
        id: 1,
        title: 'Original',
        description: 'Original Description',
        name: 'ORIG123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      final copy = original.copyWith(
        title: 'Updated',
        cardType: CardType.barcode,
      );

      expect(copy.id, 1); // unchanged
      expect(copy.title, 'Updated'); // changed
      expect(copy.description, 'Original Description'); // unchanged
      expect(copy.name, 'ORIG123'); // unchanged
      expect(copy.cardType, CardType.barcode); // changed
      expect(copy.sortOrder, 0); // unchanged
    });

    test('should validate data using renderer', () {
      final qrCard = CardItem(
        title: 'QR Card',
        description: 'Test',
        name: 'Valid QR Data',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      final barcodeCard = CardItem(
        title: 'Barcode Card',
        description: 'Test',
        name: 'ABC123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      final invalidBarcodeCard = CardItem(
        title: 'Invalid Barcode',
        description: 'Test',
        name: 'AB', // too short
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      expect(qrCard.isDataValid, true);
      expect(barcodeCard.isDataValid, true);
      expect(invalidBarcodeCard.isDataValid, false);
    });

    test('should provide access to code renderer', () {
      final qrCard = CardItem(
        title: 'QR Card',
        description: 'Test',
        name: 'Test123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      );

      final barcodeCard = CardItem(
        title: 'Barcode Card',
        description: 'Test',
        name: 'Test123',
        cardType: CardType.barcode,
        sortOrder: 0,
      );

      expect(qrCard.codeRenderer, isA<QRCodeRenderer>());
      expect(barcodeCard.codeRenderer, isA<BarcodeRenderer>());
    });
  });
}
