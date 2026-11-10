import 'package:fpdart/fpdart.dart';

import '../models/card_item.dart';
import '../utils/result.dart';
import 'card_repository_interface.dart';

/// Backend-agnostic contract for a remote card store.
///
/// Firebase, Supabase, or another cloud provider can implement this interface
/// without making the UI depend on that provider's SDK.
abstract interface class CloudCardDataSource {
  Future<Either<Failure, int>> insertCard(CardItem card);
  Future<Either<Failure, List<CardItem>>> getCards();
  Future<Either<Failure, int>> getNextSortOrder();
  Future<Either<Failure, void>> updateCardSortOrders(List<CardItem> cards);
  Future<Either<Failure, int>> deleteCard(int id);
  Future<Either<Failure, int>> updateCard(CardItem card);
  Future<Either<Failure, void>> deleteAllCards();
  Future<Either<Failure, CardItem?>> getCard(int id);
  Future<Either<Failure, int>> backfillLogoPathsFromTitles({
    bool dryRun = true,
  });
}

/// Repository adapter for a remote data source.
///
/// Keeping this adapter separate from the provider implementation gives the
/// application one repository contract for both local and cloud persistence.
class CloudCardRepository implements CardRepository {
  final CloudCardDataSource _dataSource;

  const CloudCardRepository({required CloudCardDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failure, int>> insertCard(CardItem card) =>
      _dataSource.insertCard(card);

  @override
  Future<Either<Failure, List<CardItem>>> getCards() => _dataSource.getCards();

  @override
  Future<Either<Failure, int>> getNextSortOrder() =>
      _dataSource.getNextSortOrder();

  @override
  Future<Either<Failure, void>> updateCardSortOrders(List<CardItem> cards) =>
      _dataSource.updateCardSortOrders(cards);

  @override
  Future<Either<Failure, int>> deleteCard(int id) => _dataSource.deleteCard(id);

  @override
  Future<Either<Failure, int>> updateCard(CardItem card) =>
      _dataSource.updateCard(card);

  @override
  Future<Either<Failure, void>> deleteAllCards() =>
      _dataSource.deleteAllCards();

  @override
  Future<Either<Failure, CardItem?>> getCard(int id) => _dataSource.getCard(id);

  @override
  Future<Either<Failure, int>> backfillLogoPathsFromTitles({
    bool dryRun = true,
  }) => _dataSource.backfillLogoPathsFromTitles(dryRun: dryRun);
}
