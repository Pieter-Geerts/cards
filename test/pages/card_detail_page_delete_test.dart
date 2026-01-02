import 'package:cards/controllers/card_detail_controller.dart';
import 'package:cards/helpers/i_database_helper.dart';
import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/pages/card_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FailingDbHelper implements IDatabaseHelper {
  @override
  Future<int> deleteCard(int id) => throw Exception('DB delete failed');

  @override
  Future<int> insertCard(CardItem card) async => 1;
  @override
  Future<List<CardItem>> getCards() async => [];
  @override
  Future<int> getNextSortOrder() async => 0;
  @override
  Future<void> updateCardSortOrders(List<CardItem> cards) async {}
  @override
  Future<int> updateCard(CardItem card) async => 0;
  @override
  Future<void> deleteAllCards() async {}
  @override
  Future<CardItem?> getCard(int id) async => null;
  @override
  Future<int> backfillLogoPathsFromTitles({bool dryRun = true}) async => 0;
}

void main() {
  testWidgets('CardDetailPage shows deleteFailed SnackBar on DB error', (
    WidgetTester tester,
  ) async {
    final card = CardItem(
      id: 42,
      title: 'Delete test',
      description: 'Test card for delete failure',
      name: 'ABC123',
      cardType: CardType.barcode,
      sortOrder: 0,
      logoPath: null,
    );

    final controller = CardDetailController(
      card: card,
      dbHelper: FailingDbHelper(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CardDetailPage(
            card: card,
            controller: controller,
            onDelete: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the delete icon in the AppBar
    final deleteButton = find.byIcon(Icons.delete);
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Confirm the dialog's delete action
    final confirmButton = find.text('Delete');
    expect(confirmButton, findsWidgets);
    await tester.tap(confirmButton.first);
    await tester.pumpAndSettle();

    // After the failing delete, a SnackBar with deleteFailed text should appear
    final snackBarFinder = find.byType(SnackBar);
    expect(snackBarFinder, findsOneWidget);
  });
}
