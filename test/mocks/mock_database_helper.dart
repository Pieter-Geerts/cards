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
    return _cardsStore.values.toList();
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

  @override
  Future<int> getNextSortOrder() async {
    if (_cardsStore.isEmpty) {
      return 0;
    }
    final maxOrder = _cardsStore.values
        .map((card) => card.sortOrder)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  // Reset method for testing - clears all data and resets state
  void reset() {
    _cardsStore.clear();
    _nextId = 1;
  }
}
