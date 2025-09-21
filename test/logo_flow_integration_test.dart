import 'package:cards/models/card_item.dart';
import 'package:cards/utils/simple_icons_mapping.dart';
import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_icons/simple_icons.dart';

void main() {
  group('Logo Flow Integration Tests', () {
    testWidgets('Complete logo flow should work correctly', (
      WidgetTester tester,
    ) async {
      // 1. Test creating a card with a logo
      final card = CardItem(
        title: 'Starbucks Coffee',
        description: 'My loyalty card',
        name: '1234567890',
        cardType: CardType.qrCode,
        logoPath: SimpleIconsMapping.getIdentifier(SimpleIcons.starbucks),
        sortOrder: 0,
      );

      expect(card.logoPath, equals('simple_icon:starbucks'));

      // 2. Test that LogoAvatarWidget displays the logo correctly
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoAvatarWidget(
              logoKey: card.logoPath,
              title: card.title,
              size: 48,
            ),
          ),
        ),
      );

      // Should find the Starbucks icon, not initials
      expect(find.byIcon(SimpleIcons.starbucks), findsOneWidget);
      expect(find.text('ST'), findsNothing);
    });

    testWidgets('LogoAvatarWidget should handle invalid logoPath gracefully', (
      WidgetTester tester,
    ) async {
      // Test with invalid logo path - should fall back to initials
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoAvatarWidget(
              logoKey: 'simple_icon:nonexistent',
              title: 'Test Card',
              size: 48,
            ),
          ),
        ),
      );

      // Should fall back to initials since the icon doesn't exist
      expect(find.text('TE'), findsOneWidget);
    });

    testWidgets('LogoAvatarWidget should handle null logoPath', (
      WidgetTester tester,
    ) async {
      // Test with null logo path - should show initials
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LogoAvatarWidget(logoKey: null, title: 'Test Card', size: 48),
          ),
        ),
      );

      // Should show initials
      expect(find.text('TE'), findsOneWidget);
    });
  });
}
