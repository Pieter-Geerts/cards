import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('List reference equality test - demonstrating the bug', () {
    // Create initial list
    List<CardItem> originalList = [
      CardItem(
        id: 1,
        title: 'Original Title',
        description: 'desc',
        name: 'code',
        cardType: CardType.barcode,
        sortOrder: 0,
      ),
    ];

    // Simulate the old buggy behavior
    List<CardItem> modifiedListBuggy = originalList;
    modifiedListBuggy[0] = CardItem(
      id: 1,
      title: 'Updated Title',
      description: 'desc',
      name: 'code',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    // This will be true (bug!) - same reference
    expect(identical(originalList, modifiedListBuggy), isTrue);

    // Simulate the fixed behavior
    List<CardItem> modifiedListFixed = List.from(originalList);
    modifiedListFixed[0] = CardItem(
      id: 1,
      title: 'Updated Title',
      description: 'desc',
      name: 'code',
      cardType: CardType.barcode,
      sortOrder: 0,
    );

    // This will be false (correct!) - different references
    expect(identical(originalList, modifiedListFixed), isFalse);
  });
}
