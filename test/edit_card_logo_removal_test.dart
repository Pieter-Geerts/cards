import 'package:cards/models/card_item.dart';
import 'package:cards/pages/edit_card_page.dart';
import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';
import 'mocks/mock_card_repository.dart';

void main() {
  group('Edit Card - Logo Removal Integration Tests', () {
    late MockCardRepository cardRepository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      cardRepository = MockCardRepository();
    });

    testWidgets(
      'Removing a logo from existing card persists null to repository',
      (WidgetTester tester) async {
        // Arrange: Create a card with an SVG logo path
        final cardWithLogo = CardItem(
          id: 1,
          title: 'Coffee Shop',
          description: 'My favorite café',
          name: 'CAFE123456',
          cardType: CardType.qrCode,
          logoPath: '/path/to/logo.svg', // Simulated SVG logo path
          sortOrder: 0,
          createdAt: DateTime.now(),
        );

        // Insert card into mock repository
        await cardRepository.insertCard(cardWithLogo);
        var cards = await cardRepository.getCards();
        expect(cards.length, 1);
        expect(cards[0].logoPath, '/path/to/logo.svg');

        // Track updates in the repository
        CardItem? savedCard;

        // Act: Navigate to EditCardPage
        await tester.pumpWidget(
          TestableWidget(
            child: EditCardPage(
              card: cardWithLogo,
              onSave: (updatedCard) async {
                // Simulate repository update
                savedCard = updatedCard;
                await cardRepository.updateCard(updatedCard);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert: Edit page shows "Remove Logo" button
        expect(find.text('Logo Verwijderen'), findsOneWidget);

        // Act: Remove the logo by tapping "Remove Logo" button
        await tester.tap(find.text('Logo Verwijderen'));
        await tester.pumpAndSettle();

        // Assert: Logo should be removed from UI, "Add Logo" button should appear
        expect(find.text('Logo Verwijderen'), findsNothing);
        expect(find.text('Voeg Logo Toe'), findsOneWidget);

        // Act: Save the card
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // Assert: Should pop the edit page and return
        expect(find.byType(EditCardPage), findsNothing);

        // Assert: Saved card should have null logoPath
        expect(savedCard, isNotNull);
        expect(
          savedCard!.logoPath,
          isNull,
          reason: 'logoPath should be null after removal',
        );

        // Assert: Repository should have the updated card with null logoPath
        final updatedCards = await cardRepository.getCards();
        expect(updatedCards.length, 1);
        expect(
          updatedCards[0].logoPath,
          isNull,
          reason: 'logoPath should be null in repository',
        );
      },
    );

    testWidgets('copyWith correctly handles explicit null logoPath', (
      WidgetTester tester,
    ) async {
      // This test verifies the copyWith sentinel fix at the model level
      final cardWithLogo = CardItem(
        id: 1,
        title: 'Test',
        description: 'Test',
        name: 'TEST123',
        cardType: CardType.qrCode,
        logoPath: '/path/to/logo.svg',
        sortOrder: 0,
      );

      // Act: Use copyWith with explicit null
      final cardWithoutLogo = cardWithLogo.copyWith(logoPath: null);

      // Assert: logoPath should be null, not the original value
      expect(cardWithoutLogo.logoPath, isNull);
      expect(cardWithoutLogo.title, 'Test'); // Other fields unchanged
      expect(cardWithoutLogo.id, 1);
    });

    testWidgets('copyWith preserves logoPath when not specified', (
      WidgetTester tester,
    ) async {
      // This test ensures backward compatibility
      final cardWithLogo = CardItem(
        id: 1,
        title: 'Test',
        description: 'Test',
        name: 'TEST123',
        cardType: CardType.qrCode,
        logoPath: '/path/to/logo.svg',
        sortOrder: 0,
      );

      // Act: Use copyWith without logoPath parameter
      final updatedCard = cardWithLogo.copyWith(title: 'Updated Title');

      // Assert: logoPath should be preserved
      expect(updatedCard.logoPath, '/path/to/logo.svg');
      expect(updatedCard.title, 'Updated Title');
    });

    testWidgets('Removed logo displays initials fallback in LogoAvatarWidget', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a card without logo
      final cardWithoutLogo = CardItem(
        id: 1,
        title: 'Coffee Shop',
        description: 'My favorite café',
        name: 'CAFE123456',
        cardType: CardType.qrCode,
        logoPath: null, // No logo
        sortOrder: 0,
      );

      // Act: Render LogoAvatarWidget with null logoPath
      await tester.pumpWidget(
        TestableWidget(
          child: Scaffold(
            body: Center(
              child: LogoAvatarWidget(
                logoKey: cardWithoutLogo.logoPath,
                title: cardWithoutLogo.title,
                size: 96,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Should display initials "CS" (Coffee Shop)
      expect(find.text('CS'), findsOneWidget);
    });

    testWidgets('Logo removal flow with mock repository integration', (
      WidgetTester tester,
    ) async {
      // Arrange: Create and insert a card with logo
      final originalCard = CardItem(
        title: 'Starbucks',
        description: 'Coffee rewards',
        name: 'STAR1234567890',
        cardType: CardType.qrCode,
        logoPath: '/assets/starbucks.svg',
        sortOrder: 0,
      );

      final cardId = await cardRepository.insertCard(originalCard);
      var allCards = await cardRepository.getCards();
      expect(allCards.length, 1);
      expect(allCards[0].logoPath, '/assets/starbucks.svg');

      // Act: Get the card and modify it (simulating edit page save)
      final cardToEdit = await cardRepository.getCard(cardId);
      expect(cardToEdit, isNotNull);

      // Remove logo using copyWith
      final modifiedCard = cardToEdit!.copyWith(logoPath: null);

      // Update in repository
      await cardRepository.updateCard(modifiedCard);

      // Assert: Repository should reflect the change
      final retrievedCard = await cardRepository.getCard(cardId);
      expect(retrievedCard!.logoPath, isNull);
      expect(retrievedCard.title, 'Starbucks');
      expect(retrievedCard.name, 'STAR1234567890');
    });

    testWidgets('Multiple edits including logo removal work correctly', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a card with logo and other fields
      final originalCard = CardItem(
        id: 1,
        title: 'Original Title',
        description: 'Original Description',
        name: 'CODE123',
        cardType: CardType.qrCode,
        logoPath: '/path/to/logo.svg',
        sortOrder: 0,
      );

      // Act: Perform multiple edits
      final step1 = originalCard.copyWith(title: 'Updated Title');
      expect(step1.logoPath, '/path/to/logo.svg'); // Logo preserved

      final step2 = step1.copyWith(description: 'Updated Description');
      expect(step2.logoPath, '/path/to/logo.svg'); // Logo still preserved

      final step3 = step2.copyWith(logoPath: null); // Remove logo
      expect(step3.logoPath, isNull); // Logo removed
      expect(step3.title, 'Updated Title'); // Title changes preserved
      expect(step3.description, 'Updated Description');
    });
  });
}
