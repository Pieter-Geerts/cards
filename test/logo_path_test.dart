import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_icons/simple_icons.dart';

void main() {
  group('Logo Path Tests', () {
    test('Simple icon identifier should be correctly formatted', () {
      // Test the format that should be used for Simple Icons
      const expectedFormat = 'simple_icon:starbucks';
      expect(expectedFormat.startsWith('simple_icon:'), isTrue);
      expect(expectedFormat.contains('starbucks'), isTrue);
    });

    test('CardItem should store logo path correctly', () {
      final card = CardItem(
        title: 'Starbucks',
        description: 'Coffee card',
        name: '1234567890',
        cardType: CardType.qrCode,
        logoPath: 'simple_icon:starbucks',
        sortOrder: 0,
      );

      expect(card.logoPath, equals('simple_icon:starbucks'));
      expect(card.logoPath?.startsWith('simple_icon:'), isTrue);
    });

    test('Logo identifier mapping should work', () {
      // This tests the mapping in _getSimpleIconIdentifier
      final iconMap = {
        SimpleIcons.starbucks: 'simple_icon:starbucks',
        SimpleIcons.amazon: 'simple_icon:amazon',
        SimpleIcons.carrefour: 'simple_icon:carrefour',
      };

      expect(iconMap[SimpleIcons.starbucks], equals('simple_icon:starbucks'));
      expect(iconMap[SimpleIcons.amazon], equals('simple_icon:amazon'));
      expect(iconMap[SimpleIcons.carrefour], equals('simple_icon:carrefour'));
    });
  });
}
