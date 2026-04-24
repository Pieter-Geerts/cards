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
      expect(
        CardTypeExtension.fromLegacyValue('INVALID'),
        CardType.qrCode,
      ); // fallback
      expect(
        CardTypeExtension.fromLegacyValue(''),
        CardType.qrCode,
      ); // fallback
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
      expect(card.isTemporary, false);
      expect(card.expiresAt, isNull);
    });

    test('should create temp card with expiration days', () {
      final card = CardItem.temp(
        title: 'Temp Card',
        description: 'Temporary',
        name: 'TEMP123',
        expiresInDays: 3,
      );

      expect(card.isTemporary, true);
      expect(card.expiresAt, isNotNull);
      expect(card.isExpired(DateTime.now().add(const Duration(days: 4))), true);
      expect(
        card.isExpired(DateTime.now().subtract(const Duration(days: 1))),
        false,
      );
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
      expect(map['expiresAt'], isNull);
    });

    test('should serialize expiresAt when set', () {
      final expiresAt = DateTime.now().add(const Duration(days: 7));
      final card = CardItem(
        id: 124,
        title: 'Temporary Card',
        description: 'Expires soon',
        name: 'TMP123',
        sortOrder: 2,
        expiresAt: expiresAt,
      );

      final map = card.toMap();

      expect(map['expiresAt'], expiresAt.millisecondsSinceEpoch);
    });

    test('should deserialize from map with new enum format', () {
      final map = {
        'id': 456,
        'title': 'Saved Card',
        'description': 'From Database',
        'name': 'SAVED123',
        'cardType': 'barcode', // new enum format
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'expiresAt':
            DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch,
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
      expect(card.expiresAt, isNotNull);
      expect(card.isTemporary, true);
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

  group('CardItem expiry validation', () {
    test('should identify non-temporary card as not expired', () {
      final card = CardItem(
        title: 'Permanent Card',
        description: 'No expiry',
        name: 'PERM123',
        sortOrder: 0,
      );

      expect(card.isTemporary, false);
      expect(card.expiresAt, isNull);
      expect(card.isExpired(), false);
      expect(
        card.isExpired(DateTime.now().add(const Duration(days: 100))),
        false,
      );
    });

    test('should identify card as expired when expiresAt is today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final card = CardItem(
        title: 'Expiring Today',
        description: 'Expires today',
        name: 'EXP123',
        sortOrder: 0,
        expiresAt: today,
      );

      expect(card.isTemporary, true);
      expect(card.isExpired(), true);
    });

    test('should identify card as expired when expiresAt is in past', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final card = CardItem(
        title: 'Expired Card',
        description: 'Already expired',
        name: 'OLD123',
        sortOrder: 0,
        expiresAt: yesterday,
      );

      expect(card.isTemporary, true);
      expect(card.isExpired(), true);
    });

    test('should identify card as not expired when expiresAt is in future', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final card = CardItem(
        title: 'Future Expiry',
        description: 'Not expired yet',
        name: 'FUTURE123',
        sortOrder: 0,
        expiresAt: tomorrow,
      );

      expect(card.isTemporary, true);
      expect(card.isExpired(), false);
    });

    test('should correctly compare expiry against reference time', () {
      final referenceDate = DateTime(2024, 6, 15, 12, 0, 0);
      final expiryDate = DateTime(2024, 6, 15, 0, 0, 0); // same day

      final card = CardItem(
        title: 'Reference Test',
        description: 'Test reference time',
        name: 'REF123',
        sortOrder: 0,
        expiresAt: expiryDate,
      );

      // At midnight of expiry date, card should be expired
      expect(card.isExpired(referenceDate), true);
    });

    test('should handle expiry 1 second before midnight', () {
      final referenceDate = DateTime(2024, 6, 16, 0, 0, 0);
      final oneSecondBefore = DateTime(2024, 6, 15, 23, 59, 59);

      final card = CardItem(
        title: 'Microsecond Before',
        description: 'Test boundary',
        name: 'BOUNDARY123',
        sortOrder: 0,
        expiresAt: oneSecondBefore,
      );

      // At midnight of next day - card IS expired (expiry was 1 second before midnight)
      expect(card.isExpired(referenceDate), true);
    });

    test('should correctly identify multiple days expiry', () {
      final today = DateTime.now();
      final sevenDaysFromNow = today.add(const Duration(days: 7));

      final card = CardItem(
        title: 'Week Long Card',
        description: 'Valid for 7 days',
        name: 'WEEK123',
        sortOrder: 0,
        expiresAt: sevenDaysFromNow,
      );

      expect(card.isTemporary, true);
      expect(card.isExpired(), false);
      expect(
        card.isExpired(sevenDaysFromNow.add(const Duration(hours: 1))),
        true,
      );
    });

    test('should serialize expiry date to millisecondsSinceEpoch', () {
      final expiryDate = DateTime(2025, 12, 31, 23, 59, 59);
      final card = CardItem(
        title: 'Serialization Test',
        description: 'Test expiry serialization',
        name: 'SER123',
        sortOrder: 0,
        expiresAt: expiryDate,
      );

      final map = card.toMap();

      expect(map['expiresAt'], expiryDate.millisecondsSinceEpoch);
    });

    test('should deserialize expiry date from millisecondsSinceEpoch', () {
      final expiryDate = DateTime(2025, 12, 31, 23, 59, 59);
      final map = {
        'title': 'Deserialization Test',
        'description': 'Test expiry deserialization',
        'name': 'DESER123',
        'expiresAt': expiryDate.millisecondsSinceEpoch,
        'sortOrder': 0,
      };

      final card = CardItem.fromMap(map);

      expect(card.expiresAt, isNotNull);
      expect(
        card.expiresAt!.millisecondsSinceEpoch,
        expiryDate.millisecondsSinceEpoch,
      );
      expect(card.isTemporary, true);
    });

    test('should preserve expiry date when copying card', () {
      final expiryDate = DateTime.now().add(const Duration(days: 3));
      final original = CardItem(
        id: 1,
        title: 'Original',
        description: 'Original',
        name: 'ORIG123',
        sortOrder: 0,
        expiresAt: expiryDate,
      );

      final copy = original.copyWith(title: 'Updated');

      expect(copy.expiresAt, expiryDate);
      expect(copy.isTemporary, true);
      expect(copy.title, 'Updated');
    });

    test('should allow updating expiry date via copyWith', () {
      final originalExpiry = DateTime.now().add(const Duration(days: 3));
      final newExpiry = DateTime.now().add(const Duration(days: 7));

      final original = CardItem(
        id: 1,
        title: 'Original',
        description: 'Original',
        name: 'ORIG123',
        sortOrder: 0,
        expiresAt: originalExpiry,
      );

      final updated = original.copyWith(expiresAt: newExpiry);

      expect(updated.expiresAt, newExpiry);
      expect(updated.isExpired(), false);
    });

    test(
      'should calculate expiry correctly for cards created with expiresInDays',
      () {
        final beforeCreation = DateTime.now();
        final card = CardItem.temp(
          title: 'Temp Card',
          description: 'Temp',
          name: 'TEMP123',
          expiresInDays: 5,
        );

        expect(card.isTemporary, true);
        expect(card.expiresAt, isNotNull);

        final expiryDate = card.expiresAt!;
        final expectedMin = beforeCreation
            .add(const Duration(days: 5))
            .subtract(Duration(seconds: 1)); // allow 1 second buffer

        expect(expiryDate.isAfter(expectedMin), true);
      },
    );
  });
}
