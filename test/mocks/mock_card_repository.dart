import 'package:cards/models/card_item.dart';

/// A mock repository for card data used in tests
class MockCardRepository {
  final Map<int, CardItem> _cardsStore = {};
  int _nextId = 1;

  /// Insert a card and return its ID
  Future<int> insertCard(CardItem card) async {
    final id = _nextId++;
    _cardsStore[id] = card.copyWith(id: id);
    return id;
  }

  /// Get all cards
  Future<List<CardItem>> getCards() async {
    return _cardsStore.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  /// Delete a card
  Future<int> deleteCard(int id) async {
    if (_cardsStore.containsKey(id)) {
      _cardsStore.remove(id);
      return 1;
    }
    return 0;
  }

  /// Update a card
  Future<int> updateCard(CardItem card) async {
    if (card.id != null && _cardsStore.containsKey(card.id)) {
      _cardsStore[card.id!] = card;
      return 1;
    }
    return 0;
  }

  /// Get a card by ID
  Future<CardItem?> getCard(int id) async {
    return _cardsStore[id];
  }

  /// Delete all cards
  Future<void> deleteAllCards() async {
    _cardsStore.clear();
    _nextId = 1;
  }

  /// Reorder cards
  Future<void> reorderCards(List<CardItem> cards) async {
    // Update the sort order in the store
    for (final card in cards) {
      if (card.id != null) {
        _cardsStore[card.id!] = card;
      }
    }
  }

  /// Populate with test data
  Future<List<CardItem>> populateWithTestData() async {
    final cards = [
      CardItem(
        title: 'Test QR Card',
        description: 'QR code test card',
        name: 'QR123',
        cardType: CardType.qrCode,
        sortOrder: 0,
      ),
      CardItem(
        title: 'Test Barcode Card',
        description: 'Barcode test card',
        name: 'BAR123',
        cardType: CardType.barcode,
        sortOrder: 1,
      ),
      CardItem(
        title: 'Loyalty Card',
        description: 'Loyalty program card',
        name: 'LOY456',
        cardType: CardType.qrCode,
        sortOrder: 2,
      ),
    ];

    for (final card in cards) {
      await insertCard(card);
    }

    return getCards();
  }
}
