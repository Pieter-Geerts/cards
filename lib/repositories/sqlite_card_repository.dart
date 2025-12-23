import '../helpers/database_helper.dart';
import '../helpers/i_database_helper.dart';
import '../models/card_item.dart';
import '../services/error_handling_service.dart';
import '../utils/result.dart';
import 'card_repository_interface.dart';

class SqliteCardRepository implements CardRepository {
  final IDatabaseHelper _dbHelper;

  SqliteCardRepository({IDatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<Result<int>> insertCard(CardItem card) async {
    try {
      final id = await _dbHelper.insertCard(card);
      return Result.ok(id);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(e, query: 'insertCard');
      return Result.err(
        Failure('Failed to save card. Please try again.', exception: e),
      );
    }
  }

  @override
  Future<Result<List<CardItem>>> getCards() async {
    try {
      final cards = await _dbHelper.getCards();
      return Result.ok(cards);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(e, query: 'getCards');
      return Result.err(Failure('Failed to load cards.', exception: e));
    }
  }

  @override
  Future<Result<int>> getNextSortOrder() async {
    try {
      final order = await _dbHelper.getNextSortOrder();
      return Result.ok(order);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(
        e,
        query: 'getNextSortOrder',
      );
      return Result.err(Failure('Failed to determine order.', exception: e));
    }
  }

  @override
  Future<Result<void>> updateCardSortOrders(List<CardItem> cards) async {
    try {
      await _dbHelper.updateCardSortOrders(cards);
      return Result.ok(null);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(
        e,
        query: 'updateCardSortOrders',
      );
      return Result.err(Failure('Failed to update card order.', exception: e));
    }
  }

  @override
  Future<Result<int>> deleteCard(int id) async {
    try {
      final res = await _dbHelper.deleteCard(id);
      return Result.ok(res);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(e, query: 'deleteCard');
      return Result.err(Failure('Failed to delete card.', exception: e));
    }
  }

  @override
  Future<Result<int>> updateCard(CardItem card) async {
    try {
      final res = await _dbHelper.updateCard(card);
      return Result.ok(res);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(e, query: 'updateCard');
      return Result.err(Failure('Failed to update card.', exception: e));
    }
  }

  @override
  Future<Result<void>> deleteAllCards() async {
    try {
      await _dbHelper.deleteAllCards();
      return Result.ok(null);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(
        e,
        query: 'deleteAllCards',
      );
      return Result.err(Failure('Failed to clear cards.', exception: e));
    }
  }

  @override
  Future<Result<CardItem?>> getCard(int id) async {
    try {
      final card = await _dbHelper.getCard(id);
      return Result.ok(card);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(e, query: 'getCard');
      return Result.err(Failure('Failed to load card.', exception: e));
    }
  }

  @override
  Future<Result<int>> backfillLogoPathsFromTitles({bool dryRun = true}) async {
    try {
      final updated = await _dbHelper.backfillLogoPathsFromTitles(
        dryRun: dryRun,
      );
      return Result.ok(updated);
    } catch (e, st) {
      ErrorHandlingService.instance.handleDatabaseError(
        e,
        query: 'backfillLogoPathsFromTitles',
      );
      return Result.err(
        Failure('Failed to backfill logo paths.', exception: e),
      );
    }
  }
}
