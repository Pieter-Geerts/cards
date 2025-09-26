import 'package:cards/pages/home_page.dart';
import 'package:cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'helpers/test_helpers.dart';
import 'mocks/mock_card_repository.dart' as manual_mock;

// Only import the navigator observer mock from generated mocks
import 'mocks/generate_mocks.mocks.dart' show MockNavigatorObserver;

void main() {
  late MockNavigatorObserver mockNavigatorObserver;
  late manual_mock.MockCardRepository cardRepository;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    mockNavigatorObserver = MockNavigatorObserver();
    cardRepository = manual_mock.MockCardRepository();
  });

  testWidgets('HomePage displays "No cards yet" when cards list is empty', (
    WidgetTester tester,
  ) async {
    // Arrange - create HomePage with empty cards list
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: HomePage(cards: const [], onAddCard: (card) {}),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - should show the empty state
    final l10n = AppLocalizations.of(tester.element(find.byType(MaterialApp)));
    expect(find.textContaining(l10n.noCardsYet), findsOneWidget);
    expect(
      find.byType(FloatingActionButton),
      findsOneWidget,
    ); // FAB should be visible
  });

  testWidgets('HomePage displays cards when list is not empty', (
    WidgetTester tester,
  ) async {
    // Arrange - populate with sample cards
    final cards = await cardRepository.populateWithTestData();

    // Create HomePage with cards
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: HomePage(cards: cards, onAddCard: (card) {}),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - cards should be displayed
    expect(find.text('Test QR Card'), findsOneWidget);
    expect(find.text('Test Barcode Card'), findsOneWidget);
    expect(find.text('Loyalty Card'), findsOneWidget);
  });

  testWidgets('HomePage shows search icon and can toggle search mode', (
    WidgetTester tester,
  ) async {
    // Arrange - populate with sample cards
    final cards = await cardRepository.populateWithTestData();

    // Create HomePage with cards
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: HomePage(cards: cards, onAddCard: (card) {}),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - search icon should be visible initially
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);

    // Act - tap search icon to activate search mode
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Assert - clear icon should appear (search mode activated)
    expect(find.byIcon(Icons.search), findsNothing);
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('HomePage navigates to add card page when FAB is tapped', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(
      TestableWidget(
        navigatorObservers: [mockNavigatorObserver],
        child: HomePage(cards: const [], onAddCard: (card) {}),
      ),
    );
    await tester.pumpAndSettle();

    // Act - tap the FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Assert - should navigate to add card page
    verify(mockNavigatorObserver.didPush(any, any));
  });
}
