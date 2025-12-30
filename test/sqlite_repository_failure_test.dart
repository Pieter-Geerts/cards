import 'package:cards/helpers/i_database_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:cards/repositories/sqlite_card_repository.dart';
import 'package:cards/services/error_handling_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FailingDatabaseHelper implements IDatabaseHelper {
  final Object error;
  FailingDatabaseHelper([Object? error])
    : error = error ?? Exception('DB failure');

  @override
  Future<int> backfillLogoPathsFromTitles({bool dryRun = true}) async {
    throw error;
  }

  @override
  Future<void> deleteAllCards() async {
    throw error;
  }

  @override
  Future<int> deleteCard(int id) async {
    throw error;
  }

  @override
  Future<List<CardItem>> getCards() async {
    throw error;
  }

  @override
  Future<CardItem?> getCard(int id) async {
    throw error;
  }

  @override
  Future<int> getNextSortOrder() async {
    throw error;
  }

  @override
  Future<int> insertCard(CardItem card) async {
    throw error;
  }

  @override
  Future<void> updateCardSortOrders(List<CardItem> cards) async {
    throw error;
  }

  @override
  Future<int> updateCard(CardItem card) async {
    throw error;
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // Use ffi database factory for tests
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    ErrorHandlingService.instance.clearHistory();
  });

  test(
    'Repository returns Failure when DB helper throws on getCards',
    () async {
      final failingHelper = FailingDatabaseHelper();
      final repo = SqliteCardRepository(dbHelper: failingHelper);

      final result = await repo.getCards();

      expect(
        result.fold(
          (failure) => failure.message.contains('Failed to load cards'),
          (_) => false,
        ),
        isTrue,
      );

      final stats = ErrorHandlingService.instance.getErrorStats();
      expect(stats['totalErrors'] as int, greaterThanOrEqualTo(1));
    },
  );

  test('Repository returns Failure on insertCard and reports', () async {
    final failingHelper = FailingDatabaseHelper();
    final repo = SqliteCardRepository(dbHelper: failingHelper);
    final card = CardItem(
      title: 'T',
      description: 'D',
      name: 'N',
      cardType: CardType.qrCode,
      sortOrder: 0,
    );

    final res = await repo.insertCard(card);
    expect(
      res.fold(
        (failure) => failure.message.contains('Failed to save card'),
        (_) => false,
      ),
      isTrue,
    );

    final stats = ErrorHandlingService.instance.getErrorStats();
    expect(stats['totalErrors'] as int, greaterThanOrEqualTo(1));
  });
}
