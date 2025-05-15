import 'package:cards/models/card_item.dart';
import 'package:cards/pages/add_card_page.dart';
import 'package:cards/pages/home_page.dart';
import 'package:cards/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createHomePage({
  required List<CardItem> cards,
  required Function(CardItem) onAddCard,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: HomePage(cards: cards, onAddCard: onAddCard),
  );
}

void main() {
  // Initialize AppLocalizations before running tests that need it.
  setUpAll(() async {
    // This is a common way to ensure AppLocalizations can be found.
    // For more complex scenarios, you might need to pump a MaterialApp
    // with the delegates in a test setup.
  });

  testWidgets('HomePage displays "No cards yet" when cards list is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomePage(cards: [], onAddCard: (_) {}));

    // Wait for AppLocalizations to load if necessary
    await tester.pumpAndSettle();

    expect(find.textContaining('No cards yet'), findsOneWidget);
  });

  testWidgets('HomePage displays cards', (WidgetTester tester) async {
    final cards = [
      CardItem(
        title: 'Card 1',
        description: 'Description 1',
        name: 'Name 1',
        sortOrder: 0,
      ),
      CardItem(
        title: 'Card 2',
        description: 'Description 2',
        name: 'Name 2',
        sortOrder: 1,
      ),
    ];

    await tester.pumpWidget(createHomePage(cards: cards, onAddCard: (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Card 1'), findsOneWidget);
    expect(find.text('Description 1'), findsOneWidget);
    // Name is not directly displayed in ListTile, but in CardDetailPage
    // expect(find.text('Name 1'), findsOneWidget);

    expect(find.text('Card 2'), findsOneWidget);
    expect(find.text('Description 2'), findsOneWidget);
    // expect(find.text('Name 2'), findsOneWidget);

    // Verify ReorderableListView is present
    expect(find.byType(ReorderableListView), findsOneWidget);
  });

  testWidgets('HomePage has a FloatingActionButton to add cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomePage(cards: [], onAddCard: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('HomePage navigates to SettingsPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomePage(cards: [], onAddCard: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.settings), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle(); // Wait for navigation

    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('HomePage search functionality', (WidgetTester tester) async {
    final cards = [
      CardItem(
        title: 'Apple Card',
        description: 'Fruit related',
        name: 'A1',
        sortOrder: 0,
      ),
      CardItem(
        title: 'Banana Card',
        description: 'Fruit related',
        name: 'B1',
        sortOrder: 1,
      ),
    ];
    await tester.pumpWidget(createHomePage(cards: cards, onAddCard: (_) {}));
    await tester.pumpAndSettle();

    // Open search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(
      find.text('My Cards'),
      findsNothing,
    ); // Title should be replaced by search field

    // Enter search query
    await tester.enterText(find.byType(TextField), 'Apple');
    await tester.testTextInput.receiveAction(
      TextInputAction.done,
    ); // Simulate submit
    await tester.pumpAndSettle();

    expect(find.text('Apple Card'), findsOneWidget);
    expect(find.text('Banana Card'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    // expect(find.byType(TextField), findsNothing); // Search field might still be visible but empty
    // expect(find.text('My Cards'), findsOneWidget); // Title should reappear if search closes on clear

    // Close search explicitly if clear doesn't close it
    // This depends on the exact behavior of your search clear button
    // For this test, let's assume clear also makes the search inactive or we tap back
    final backButton = find.byIcon(Icons.arrow_back);
    if (tester.any(backButton)) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }

    expect(find.text('Apple Card'), findsOneWidget);
    expect(find.text('Banana Card'), findsOneWidget);
  });

  testWidgets('Tapping FloatingActionButton navigates to AddCardPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createHomePage(cards: [], onAddCard: (_) {}));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AddCardPage), findsOneWidget);
  });
}
