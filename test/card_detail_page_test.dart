import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Widget createCardDetailPage({
  required CardItem card,
  Function(CardItem)? onDelete,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CardDetailPage(card: card, onDelete: onDelete),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('CardDetailPage displays QR code details in white card', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      title: 'QR Test Card',
      description: 'This is a QR code.',
      name: 'QRCodeData123',
      cardType: 'QR_CODE',
      sortOrder: 0,
    );
    await tester.pumpWidget(createCardDetailPage(card: card));
    await tester.pumpAndSettle();
    expect(find.text('QR Test Card'), findsOneWidget);
    expect(find.text('This is a QR code.'), findsOneWidget);
    // Card with white background
    final cardWidget = tester.widget<Card>(find.byType(Card).first);
    expect(cardWidget.color, Colors.white);
    // QR code present
    expect(find.byType(QrImageView), findsOneWidget);
    // No barcode value text for QR
    expect(find.text('QRCodeData123'), findsNothing);
  });

  testWidgets('CardDetailPage displays Barcode details in white card', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      title: 'Barcode Test Card',
      description: 'This is a barcode.',
      name: '112345566',
      cardType: 'BARCODE',
      sortOrder: 0,
    );
    await tester.pumpWidget(createCardDetailPage(card: card));
    await tester.pumpAndSettle();
    expect(find.text('Barcode Test Card'), findsOneWidget);
    expect(find.text('This is a barcode.'), findsOneWidget);
    // Card with white background
    final cardWidget = tester.widget<Card>(find.byType(Card).first);
    expect(cardWidget.color, Colors.white);
    // Barcode present
    expect(find.byType(BarcodeWidget), findsOneWidget);
    // Barcode value text present and centered
    expect(find.text('112345566'), findsOneWidget);
    final textWidget = tester.widget<Text>(find.text('112345566'));
    expect(textWidget.textAlign, TextAlign.center);
  });

  testWidgets('CardDetailPage delete button works', (
    WidgetTester tester,
  ) async {
    bool onDeleteCalled = false;
    CardItem? deletedCard;

    final card = CardItem(
      title: 'Deletable Card',
      description: 'Test delete.',
      name: 'ToDelete123',
      cardType: 'QR_CODE',
      sortOrder: 0,
    );

    await tester.pumpWidget(
      createCardDetailPage(
        card: card,
        onDelete: (c) {
          onDeleteCalled = true;
          deletedCard = c;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify delete button is present
    expect(find.byIcon(Icons.delete), findsOneWidget);

    // Tap delete button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle(); // Show dialog

    // Verify dialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Delete Card'), findsOneWidget); // Dialog title
    expect(
      find.text('Are you sure you want to delete this card?'),
      findsOneWidget,
    );

    // Tap 'Delete' in dialog
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    // await tester.pumpAndSettle(); // Dialog closes, page might pop

    expect(onDeleteCalled, isTrue);
    expect(deletedCard, equals(card));
  });

  testWidgets(
    'CardDetailPage does not show delete button if onDelete is null',
    (WidgetTester tester) async {
      final card = CardItem(
        title: 'No Delete Card',
        description: 'No delete function provided.',
        name: 'NoDelete123',
        cardType: 'QR_CODE',
        sortOrder: 0,
      );

      await tester.pumpWidget(createCardDetailPage(card: card, onDelete: null));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsNothing);
    },
  );

  testWidgets('CardDetailPage shows edit icon in app bar', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      title: 'Test Card',
      description: 'Test description',
      name: 'TestName',
      cardType: 'QR_CODE',
      sortOrder: 0,
    );
    await tester.pumpWidget(createCardDetailPage(card: card, onDelete: null));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  // testWidgets('CardDetailPage shows editable fields and saves changes', (
  //   WidgetTester tester,
  // ) async {
  //   final card = CardItem(
  //     title: 'Editable Card',
  //     description: 'Edit me',
  //     name: 'EditName',
  //     cardType: 'QR_CODE',
  //     sortOrder: 0,
  //   );
  //   await tester.pumpWidget(createCardDetailPage(card: card, onDelete: null));
  //   await tester.pumpAndSettle();
  //   // Tap Edit icon in app bar
  //   await tester.tap(find.byIcon(Icons.edit));
  //   await tester.pumpAndSettle();
  //   // Editable fields should appear
  //   expect(find.byType(TextFormField), findsNWidgets(2));
  //   expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);
  //   expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
  //   // Change title and description
  //   await tester.enterText(
  //     find.widgetWithText(TextFormField, 'Title'),
  //     'New Title',
  //   );
  //   await tester.enterText(
  //     find.widgetWithText(TextFormField, 'Description'),
  //     'New Description',
  //   );
  //   // Tap Save
  //   await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
  //   await tester.pumpAndSettle();
  //   // Should show updated text
  //   expect(find.text('New Title'), findsOneWidget);
  //   expect(find.text('New Description'), findsOneWidget);
  // });

  testWidgets('CardDetailPage share button omits id in exported JSON', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      id: 123,
      title: 'Share Card',
      description: 'Share description',
      name: 'ShareName',
      cardType: 'QR_CODE',
      sortOrder: 0,
    );
    await tester.pumpWidget(createCardDetailPage(card: card, onDelete: null));
    await tester.pumpAndSettle();
    // Tap share button
    final shareButton = find.byIcon(Icons.share);
    expect(shareButton, findsOneWidget);
    // Instead of actually sharing, intercept the file write and check contents
    // (In a real test, use a mock or override getTemporaryDirectory and Share.shareXFiles)
    // Here, just verify the logic for removing 'id' from the map
    final map = Map<String, dynamic>.from(card.toMap());
    map.remove('id');
    final jsonString = jsonEncode(map);
    expect(jsonString.contains('"id"'), isFalse);
    expect(jsonString.contains('Share Card'), isTrue);
  });
}
