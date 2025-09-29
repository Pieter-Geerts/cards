import 'package:cards/pages/home_page.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  testWidgets('Search filters by title, description, name and type', (
    WidgetTester tester,
  ) async {
    // Arrange - create a few cards with distinct fields
    final cards = [
      CardItem(
        id: 1,
        title: 'Alpha Store',
        description: 'Best shop',
        name: 'A123',
        cardType: CardType.barcode,
        sortOrder: 0,
      ),
      CardItem(
        id: 2,
        title: 'Beta Cafe',
        description: 'Coffee and snacks',
        name: 'B456',
        cardType: CardType.qrCode,
        sortOrder: 1,
      ),
      CardItem(
        id: 3,
        title: 'Gamma',
        description: 'A special place',
        name: 'G789',
        cardType: CardType.barcode,
        sortOrder: 2,
      ),
    ];

    await tester.pumpWidget(
      TestableWidget(child: HomePage(cards: cards, onAddCard: (_) {})),
    );
    await tester.pumpAndSettle();

    // Activate search
    expect(find.byIcon(Icons.search), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Search by title
    await tester.enterText(find.byType(TextField), 'Beta');
    await tester.pumpAndSettle();
    expect(find.text('Beta Cafe'), findsOneWidget);
    expect(find.text('Alpha Store'), findsNothing);

    // Search by description
    await tester.enterText(find.byType(TextField), 'special');
    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Beta Cafe'), findsNothing);

    // Search by name/code
    await tester.enterText(find.byType(TextField), 'A123');
    await tester.pumpAndSettle();
    expect(find.text('Alpha Store'), findsOneWidget);

    // Search by card type (case-insensitive; 'barcode' should match barcode cards)
    await tester.enterText(find.byType(TextField), 'barcode');
    await tester.pumpAndSettle();
    // Should find at least one barcode card
    expect(find.text('Alpha Store'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
    // QR card should not be found
    expect(find.text('Beta Cafe'), findsNothing);
  });
}
