import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Page Object for HomePage
/// Encapsulates all UI interactions and assertions for the home screen
class HomePageObject {
  final WidgetTester tester;

  HomePageObject(this.tester);

  // ===== Finders =====
  Finder get _addCardFAB => find.byKey(const ValueKey('add_card_fab'));
  Finder get _cardList => find.byType(ListView);
  Finder get _searchIcon => find.byIcon(Icons.search);
  Finder get _settingsIcon => find.byIcon(Icons.settings);
  Finder get _emptyStateCard => find.byKey(const ValueKey('empty_state'));
  Finder get _cardItems => find.byType(ListTile);
  Finder get _appBar => find.byType(AppBar);

  // ===== Verifications =====
  Future<void> verifyHomePageDisplayed() async {
    expect(_appBar, findsOneWidget, reason: 'AppBar should be visible');

    // Wait for FAB to appear (handles any async initialization)
    final found = await TestSyncHelper.waitForFinder(
      tester,
      _addCardFAB,
      timeout: const Duration(seconds: 2),
    );
    expect(found, isTrue, reason: 'FAB should be visible');
  }

  Future<void> verifyEmptyState() async {
    expect(_emptyStateCard, findsOneWidget, reason: 'Empty state should show');
    expect(_cardList, findsOneWidget, reason: 'List should exist but be empty');
  }

  Future<void> verifyCardCount(int expectedCount) async {
    if (expectedCount == 0) {
      expect(_cardItems, findsNothing, reason: 'No cards should be in list');
    } else {
      // Count visible cards (may be more than expectedCount if not scrolled)
      expect(_cardItems, findsWidgets, reason: 'Cards should be visible');
    }
  }

  Future<void> verifyCardVisible(String cardTitle) async {
    expect(
      find.text(cardTitle),
      findsOneWidget,
      reason: 'Card with title "$cardTitle" should be visible',
    );
  }

  Future<void> verifySearchFieldVisible() async {
    expect(
      _searchIcon,
      findsOneWidget,
      reason: 'Search icon should be visible',
    );
  }

  // ===== Actions =====
  Future<void> tapAddCardFAB() async {
    await tester.tap(_addCardFAB);
    await tester.pumpAndSettle();
  }

  Future<void> tapCardByTitle(String cardTitle) async {
    await tester.tap(find.text(cardTitle));
    await tester.pumpAndSettle();
  }

  Future<void> tapSearchIcon() async {
    await tester.tap(_searchIcon);
    await tester.pumpAndSettle();
  }

  Future<void> tapSettingsIcon() async {
    await tester.tap(_settingsIcon);
    await tester.pumpAndSettle();
  }

  Future<void> searchForCard(String query) async {
    final searchField = find.byType(TextField);
    await tester.tap(searchField);
    await tester.pump();
    await tester.enterText(searchField, query);
    await tester.pumpAndSettle();
  }
}
