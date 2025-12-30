import 'package:fpdart/fpdart.dart';

import '../models/card_item.dart';
import '../utils/result.dart';

abstract class CardRepository {
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
