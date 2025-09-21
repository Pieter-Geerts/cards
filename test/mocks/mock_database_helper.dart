import 'package:cards/helpers/database_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {
  final Map<int, CardItem> _cardsStore = {};
  int _nextId = 1;

  @override
  Future<int> insertCard(CardItem card) async {
    final id = _nextId++;
    _cardsStore[id] = card.copyWith(id: id);
    return id;
  }

  @override
  Future<List<CardItem>> getCards() async {
    final cards = _cardsStore.values.toList();
    cards.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return cards;
  }

  @override
  Future<int> deleteCard(int id) async {
    if (_cardsStore.containsKey(id)) {
      _cardsStore.remove(id);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> updateCard(CardItem card) async {
    if (_cardsStore.containsKey(card.id)) {
      _cardsStore[card.id!] = card;
      return 1;
    }
    return 0;
  }

  @override
  Future<CardItem?> getCard(int id) async {
    return _cardsStore[id];
  }

  @override
  Future<void> deleteAllCards() async {
    _cardsStore.clear();
    _nextId = 1;
  }

  /// Reset the mock database to initial state
  void reset() {
    _cardsStore.clear();
    _nextId = 1;
  }

  @override
  Future<int> getNextSortOrder() async {
    if (_cardsStore.isEmpty) {
      return 0;
    }

    final cards = _cardsStore.values.toList();
    final maxOrder = cards
        .map((c) => c.sortOrder)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  @override
  Future<void> updateCardSortOrders(List<CardItem> cards) async {
    for (var card in cards) {
      if (card.id != null && _cardsStore.containsKey(card.id)) {
        _cardsStore[card.id!] = card;
      }
    }
  }
}
