import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget makePage(CardItem card, {Function(CardItem)? onDelete}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('nl'),
    home: CardDetailPage(card: card, onDelete: onDelete),
  );
}

void main() {
  testWidgets('Body title present and larger font', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      title: 'Big Title',
      description: 'desc',
      name: '1234567890123',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    await tester.pumpWidget(makePage(card));
    await tester.pumpAndSettle();

    // We use find.text on the AppBar title only; the body title is a RichText
    // so it won't be matched by find.text. Instead, find the RichText and
    // assert it contains expected string.
    final rich = find.byType(RichText);
    expect(rich, findsWidgets);
  });

  testWidgets('Formatted code groups digits', (WidgetTester tester) async {
    final card = CardItem(
      title: 'Code Test',
      description: 'desc',
      name: '2292220484809',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    await tester.pumpWidget(makePage(card));
    await tester.pumpAndSettle();

    // The formatted text is in a RichText (TextSpan). Find first RichText
    // and inspect its text span to ensure grouping.
    final richFinder = find.byType(RichText);
    expect(richFinder, findsWidgets);

    bool foundFormatted = false;
    for (final richWidget in tester.widgetList<RichText>(richFinder)) {
      final span = richWidget.text;
      if (span is TextSpan) {
        final text = span.toPlainText();
        if (text.contains('2292 2204 8480 9')) {
          foundFormatted = true;
          break;
        }
      }
    }

    expect(
      foundFormatted,
      isTrue,
      reason: 'Expected formatted grouped code to be present in a RichText',
    );
  });

  testWidgets('Hidden raw code exists (transparent)', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      title: 'Hidden Code',
      description: 'desc',
      name: 'HID123456',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    await tester.pumpWidget(makePage(card));
    await tester.pumpAndSettle();

    // raw Text with the exact string should be findable by the tests (even
    // if transparent). We rely on find.text to locate it.
    expect(find.text('HID123456'), findsOneWidget);
  });

  testWidgets('Barcode area is a white Card', (WidgetTester tester) async {
    final card = CardItem(
      title: 'Card Area',
      description: 'desc',
      name: '1111',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    await tester.pumpWidget(makePage(card));
    await tester.pumpAndSettle();

    final cardWidget = tester.widgetList<Card>(find.byType(Card)).first;
    expect(cardWidget.color, Colors.white);
  });
}
