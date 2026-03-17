import 'package:cards/models/card_item.dart';
import 'package:cards/widgets/card_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  CardItem _baseCard({DateTime? expiresAt}) {
    return CardItem(
      id: 1,
      title: 'Test Card',
      description: 'Description',
      name: '1234567890',
      sortOrder: 0,
      expiresAt: expiresAt,
    );
  }

  testWidgets('shows expires badge when expiresAt exists', (tester) async {
    final card = _baseCard(expiresAt: DateTime(2026, 3, 20));

    await tester.pumpWidget(
      _wrap(CardItemWidget(card: card, onTap: () {}, onActions: () {})),
    );

    expect(find.textContaining('Expires on'), findsOneWidget);
  });

  testWidgets('does not show expires badge when expiresAt is null', (
    tester,
  ) async {
    final card = _baseCard();

    await tester.pumpWidget(
      _wrap(CardItemWidget(card: card, onTap: () {}, onActions: () {})),
    );

    expect(find.textContaining('Expires on'), findsNothing);
  });
}
