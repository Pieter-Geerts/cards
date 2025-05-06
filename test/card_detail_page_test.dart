import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('CardDetailPage displays card details and QR code', (
    WidgetTester tester,
  ) async {
    // Create a card
    final card = CardItem(
      title: 'Card Title',
      description: 'Card Description',
      name: 'Card Name',
    );

    // Build the CardDetailPage widget
    await tester.pumpWidget(MaterialApp(home: CardDetailPage(card: card)));

    // Verify the card details are displayed
    expect(find.text('Card Title'), findsOneWidget);
    expect(find.text('Card Description'), findsOneWidget);

    // Verify the QR code is displayed
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
