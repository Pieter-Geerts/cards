import '../models/card_item.dart';

abstract class IDatabaseHelper {
  Future<int> insertCard(CardItem card);
  Future<List<CardItem>> getCards();
  Future<int> getNextSortOrder();
  Future<void> updateCardSortOrders(List<CardItem> cards);
  Future<int> deleteCard(int id);
  Future<int> updateCard(CardItem card);
  Future<void> deleteAllCards();
  Future<CardItem?> getCard(int id);
  Future<int> backfillLogoPathsFromTitles({bool dryRun = true});
}
