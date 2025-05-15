import 'package:barcode_widget/barcode_widget.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  testWidgets('CardDetailPage displays QR code details', (
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
    expect(find.text('Type: QR_CODE'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.byType(BarcodeWidget), findsNothing);
  });

  testWidgets('CardDetailPage displays Barcode details', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      title: 'Barcode Test Card',
      description: 'This is a barcode.',
      name: 'BarcodeData123',
      cardType: 'BARCODE',
      sortOrder: 0,
    );

    await tester.pumpWidget(createCardDetailPage(card: card));
    await tester.pumpAndSettle();

    expect(find.text('Barcode Test Card'), findsOneWidget);
    expect(find.text('This is a barcode.'), findsOneWidget);
    expect(find.text('Type: BARCODE'), findsOneWidget);
    expect(find.byType(BarcodeWidget), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
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
}
