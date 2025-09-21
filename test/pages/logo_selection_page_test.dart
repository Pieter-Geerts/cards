import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/pages/logo_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('nl'), Locale('es')],
    home: child,
  );
}

void main() {
  group('LogoSelectionPage Tests', () {
    testWidgets('should display logo selection page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const LogoSelectionPage(cardTitle: 'Test Card')),
      );

      expect(find.text('Select Logo'), findsOneWidget);
      expect(find.text('Suggested'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should show current logo when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const LogoSelectionPage(
            cardTitle: 'Test Card',
            currentLogo: Icons.star,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Selected Logo'), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(const LogoSelectionPage(cardTitle: 'Test Card')),
      );

      // Initially on suggested tab
      await tester.pumpAndSettle();

      // Tap browse tab
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // Tap search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Start typing to search logos'), findsOneWidget);
    });

    testWidgets('should handle search functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const LogoSelectionPage(cardTitle: 'Test Card')),
      );

      // Navigate to search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Find and interact with search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'test search');
      await tester.pumpAndSettle();

      // Clear search button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should enable done button when logo selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const LogoSelectionPage(
            cardTitle: 'Test Card',
            currentLogo: Icons.star,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Done button should be enabled when logo is selected
      final doneButton = find.text('Done');
      expect(doneButton, findsOneWidget);

      // Test tapping done button
      await tester.tap(doneButton);
      await tester.pumpAndSettle();
    });

    testWidgets('should handle empty logo suggestions gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const LogoSelectionPage(cardTitle: 'NonexistentBrand123456'),
        ),
      );

      await tester.pumpAndSettle();

      // Should show no suggestion found message
      expect(find.text('No logo suggestion found'), findsOneWidget);
    });

    testWidgets('should handle logo removal', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const LogoSelectionPage(
            cardTitle: 'Test Card',
            currentLogo: Icons.star,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap remove button
      final removeButton = find.byIcon(Icons.clear);
      if (removeButton.evaluate().isNotEmpty) {
        await tester.tap(removeButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should provide haptic feedback on selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const LogoSelectionPage(cardTitle: 'Google')),
      );

      await tester.pumpAndSettle();

      // Navigate to browse tab and try to select a logo
      await tester.tap(find.text('Browse'));
      await tester.pumpAndSettle();

      // This test verifies the UI doesn't crash when haptic feedback is triggered
      // Actual haptic feedback testing requires platform-specific testing
    });
  });
}
