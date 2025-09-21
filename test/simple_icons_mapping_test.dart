import 'package:cards/utils/simple_icons_mapping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_icons/simple_icons.dart';

void main() {
  group('Simple Icons Mapping Tests', () {
    test('Should convert icon to identifier correctly', () {
      final identifier = SimpleIconsMapping.getIdentifier(
        SimpleIcons.starbucks,
      );
      expect(identifier, equals('simple_icon:starbucks'));
    });

    test('Should convert identifier to icon correctly', () {
      final icon = SimpleIconsMapping.getIcon('simple_icon:starbucks');
      expect(icon, equals(SimpleIcons.starbucks));
    });

    test('Should return null for unsupported icon', () {
      final identifier = SimpleIconsMapping.getIdentifier(SimpleIcons.x);
      expect(identifier, isNull);
    });

    test('Should return null for invalid identifier', () {
      final icon = SimpleIconsMapping.getIcon('simple_icon:invalid');
      expect(icon, isNull);
    });

    test('Should validate identifiers correctly', () {
      expect(
        SimpleIconsMapping.isValidIdentifier('simple_icon:starbucks'),
        isTrue,
      );
      expect(
        SimpleIconsMapping.isValidIdentifier('simple_icon:invalid'),
        isFalse,
      );
      expect(
        SimpleIconsMapping.isValidIdentifier('invalid:starbucks'),
        isFalse,
      );
    });

    test('Should check if icon is supported', () {
      expect(SimpleIconsMapping.isSupported(SimpleIcons.starbucks), isTrue);
      expect(SimpleIconsMapping.isSupported(SimpleIcons.x), isFalse);
    });

    test('Should return available icons', () {
      final icons = SimpleIconsMapping.getAllIcons();
      expect(icons, isNotEmpty);
      expect(icons, contains(SimpleIcons.starbucks));
      expect(icons, contains(SimpleIcons.amazon));
    });
  });
}
