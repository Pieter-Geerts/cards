import 'package:cards/models/card_item.dart';
import 'package:cards/widgets/code_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CodeCardWidget shows white card and raw invisible text', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      id: 1,
      title: 'Test Card',
      description: '',
      name: '123456789012',
      cardType: CardType.barcode,
      sortOrder: 0,
      logoPath: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CodeCardWidget(
              card: card,
              maxWidth: 300,
              showLogo: false,
              logoOverlay: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // The white card should be present (Card widget with white Container)
    final cardFinder = find.byType(Card);
    expect(cardFinder, findsOneWidget);

    // The formatted display (grouped digits) should be visible as Text
    final groupedTextFinder = find.textContaining('1234');
    expect(groupedTextFinder, findsWidgets);

    // Raw code must be present as invisible text for tests and export
    final rawFinder = find.byWidgetPredicate((w) {
      if (w is Opacity) {
        final child = w.child;
        return child is Text &&
            child.data == '123456789012' &&
            w.opacity == 0.0;
      }
      return false;
    });

    expect(rawFinder, findsOneWidget);
  });
}
