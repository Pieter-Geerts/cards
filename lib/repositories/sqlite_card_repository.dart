import 'package:fpdart/fpdart.dart';

import '../helpers/database_helper.dart';
import '../helpers/i_database_helper.dart';
import '../models/card_item.dart';
import '../services/error_handling_service.dart';
import '../utils/result.dart';
import 'card_repository_interface.dart';

class SqliteCardRepository implements CardRepository {
  final IDatabaseHelper _dbHelper;
  final ErrorHandlingService _errorHandlingService;

  SqliteCardRepository({
    IDatabaseHelper? dbHelper,
    ErrorHandlingService? errorHandlingService,
  }) : _dbHelper = dbHelper ?? DatabaseHelper(),
       _errorHandlingService =
           errorHandlingService ?? ErrorHandlingService.instance;

  @override
  Future<Either<Failure, int>> insertCard(CardItem card) async {
    try {
      final id = await _dbHelper.insertCard(card);
      return Right(id);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'insertCard');
      return Left(
        Failure('Failed to save card. Please try again.', exception: e),
      );
    }
  }

  @override
  Future<Either<Failure, List<CardItem>>> getCards() async {
    try {
      final cards = await _dbHelper.getCards();
      return Right(cards);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'getCards');
      return Left(Failure('Failed to load cards.', exception: e));
    }
  }

  @override
  Future<Either<Failure, int>> getNextSortOrder() async {
    try {
      final order = await _dbHelper.getNextSortOrder();
      return Right(order);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'getNextSortOrder');
      return Left(Failure('Failed to determine order.', exception: e));
    }
  }

  @override
  Future<Either<Failure, void>> updateCardSortOrders(
    List<CardItem> cards,
  ) async {
    try {
      await _dbHelper.updateCardSortOrders(cards);
      return const Right(null);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'updateCardSortOrders');
      return Left(Failure('Failed to update card order.', exception: e));
    }
  }

  @override
  Future<Either<Failure, int>> deleteCard(int id) async {
    try {
      final res = await _dbHelper.deleteCard(id);
      return Right(res);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'deleteCard');
      return Left(Failure('Failed to delete card.', exception: e));
    }
  }

  @override
  Future<Either<Failure, int>> updateCard(CardItem card) async {
    try {
      final res = await _dbHelper.updateCard(card);
      return Right(res);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'updateCard');
      return Left(Failure('Failed to update card.', exception: e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllCards() async {
    try {
      await _dbHelper.deleteAllCards();
      return const Right(null);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'deleteAllCards');
      return Left(Failure('Failed to clear cards.', exception: e));
    }
  }

  @override
  Future<Either<Failure, CardItem?>> getCard(int id) async {
    try {
      final card = await _dbHelper.getCard(id);
      return Right(card);
    } catch (e, st) {
      _errorHandlingService.handleError(e, st, context: 'getCard');
      return Left(Failure('Failed to load card.', exception: e));
    }
  }

  @override
  Future<Either<Failure, int>> backfillLogoPathsFromTitles({
    bool dryRun = true,
  }) async {
    try {
      final updated = await _dbHelper.backfillLogoPathsFromTitles(
        dryRun: dryRun,
      );
      return Right(updated);
    } catch (e, st) {
      _errorHandlingService.handleError(
        e,
        st,
        context: 'backfillLogoPathsFromTitles',
      );
      return Left(Failure('Failed to backfill logo paths.', exception: e));
    }
  }
}
