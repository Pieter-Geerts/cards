import 'package:cards/models/card_item.dart';
import 'package:cards/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomePage displays cards', (WidgetTester tester) async {
    // Create a list of cards
    final cards = [
      CardItem(title: 'Card 1', description: 'Description 1', name: 'Name 1'),
      CardItem(title: 'Card 2', description: 'Description 2', name: 'Name 2'),
    ];

    // Build the HomePage widget
    await tester.pumpWidget(
      MaterialApp(home: HomePage(cards: cards, onAddCard: (_) {})),
    );

    // Verify the cards are displayed
    expect(find.text('Card 1'), findsOneWidget);
    expect(find.text('Description 1'), findsOneWidget);
    expect(find.text('Name 1'), findsOneWidget);

    expect(find.text('Card 2'), findsOneWidget);
    expect(find.text('Description 2'), findsOneWidget);
    expect(find.text('Name 2'), findsOneWidget);
  });
}
