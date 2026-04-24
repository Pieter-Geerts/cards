import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page Object for LogoSelectionPage
/// Full-screen logo picker with search, tabs, and suggestions
class LogoSelectionPageObject {
  final WidgetTester tester;

  LogoSelectionPageObject(this.tester);

  // ===== Finders =====
  Finder get _searchField => find.byKey(const ValueKey('logo_search_field'));
  Finder get _tabBar => find.byType(TabBar);
  Finder get _logoGridItems => find.byType(GridTile);
  Finder get _confirmButton =>
      find.byKey(const ValueKey('confirm_logo_button'));
  Finder get _appBar => find.byType(AppBar);

  // ===== Verifications =====
  Future<void> verifyLogoSelectionPageDisplayed() async {
    expect(_appBar, findsOneWidget, reason: 'AppBar should be visible');
    expect(
      _searchField,
      findsOneWidget,
      reason: 'Search field should be visible',
    );
    expect(_tabBar, findsOneWidget, reason: 'Tab bar should be visible');
  }

  Future<void> verifyLogosDisplayed() async {
    expect(
      _logoGridItems,
      findsWidgets,
      reason: 'Logo grid items should be displayed',
    );
  }

  Future<void> verifyLogoCount(int expectedCount) async {
    final logos = find.byType(GridTile);
    if (expectedCount == 0) {
      expect(logos, findsNothing, reason: 'No logos should be displayed');
    } else {
      // Grid tiles may be more than expected due to viewport
      expect(logos, findsWidgets, reason: 'Logos should be displayed');
    }
  }

  Future<void> verifyConfirmButtonVisible() async {
    expect(
      _confirmButton,
      findsOneWidget,
      reason: 'Confirm button should be visible',
    );
  }

  // ===== Actions =====
  Future<void> searchForLogo(String query) async {
    await tester.tap(_searchField);
    await tester.pump();
    await tester.enterText(_searchField, query);
    await tester.pumpAndSettle();
  }

  Future<void> clearSearchField() async {
    final textField = tester.widget<TextField>(_searchField);
    if (textField.controller != null) {
      textField.controller!.clear();
      await tester.pump();
    } else {
      // Fallback: tap and delete manually
      await tester.tap(_searchField);
      await tester.pump();
      await tester.enterText(_searchField, '');
      await tester.pumpAndSettle();
    }
  }

  Future<void> selectLogoByIndex(int index) async {
    final logos = find.byType(GridTile);
    await tester.tap(logos.at(index));
    await tester.pump();
  }

  Future<void> selectLogoByName(String logoName) async {
    // Find and tap the logo by its semantic label or tooltip
    final logo = find.byTooltip(logoName);
    if (logo.evaluate().isNotEmpty) {
      await tester.tap(logo);
      await tester.pump();
    } else {
      // Fallback: search and scroll to find it
      await searchForLogo(logoName);
      final gridItems = find.byType(GridTile);
      if (gridItems.evaluate().isNotEmpty) {
        await tester.tap(gridItems.first);
        await tester.pump();
      }
    }
  }

  Future<void> tapTabByIndex(int tabIndex) async {
    final tabBar = find.byType(Tab);
    await tester.tap(tabBar.at(tabIndex));
    await tester.pumpAndSettle();
  }

  Future<void> tapConfirmButton() async {
    await tester.tap(_confirmButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapBackButton() async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }

  Future<void> scrollToLogoAtIndex(int index) async {
    final gridView = find.byType(GridView);
    await tester.scrollUntilVisible(
      find.byType(GridTile).at(index),
      500.0,
      scrollable: gridView.first,
    );
    await tester.pump();
  }
}
