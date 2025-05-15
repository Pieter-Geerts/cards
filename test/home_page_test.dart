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
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.noCardsYet), findsOneWidget);
  });

  // testWidgets('HomePage displays cards', (WidgetTester tester) async {
  //   final cards = [
  //     CardItem(
  //       title: 'Card 1',
  //       description: 'Description 1',
  //       name: 'Name 1',
  //       sortOrder: 0,
  //     ),
  //     CardItem(
  //       title: 'Card 2',
  //       description: 'Description 2',
  //       name: 'Name 2',
  //       sortOrder: 1,
  //     ),
  //   ];
  //   await tester.pumpWidget(createHomePage(cards: cards, onAddCard: (_) {}));
  //   await tester.pumpAndSettle();
  //
  //   expect(find.text('Card 1'), findsOneWidget);
  //   expect(find.text('Description 1'), findsOneWidget);
  //   expect(find.text('Card 2'), findsOneWidget);
  //   expect(find.text('Description 2'), findsOneWidget);
  //   expect(find.byType(ReorderableListView), findsOneWidget);
  // });

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
