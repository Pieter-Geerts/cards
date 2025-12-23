import '../models/card_item.dart';
import '../utils/result.dart';

abstract class CardRepository {
  Future<Result<int>> insertCard(CardItem card);
  Future<Result<List<CardItem>>> getCards();
  Future<Result<int>> getNextSortOrder();
  Future<Result<void>> updateCardSortOrders(List<CardItem> cards);
  Future<Result<int>> deleteCard(int id);
  Future<Result<int>> updateCard(CardItem card);
  Future<Result<void>> deleteAllCards();
  Future<Result<CardItem?>> getCard(int id);
  Future<Result<int>> backfillLogoPathsFromTitles({bool dryRun = true});
}
