import 'package:cards/helpers/database_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize the database factory for tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final dbHelper = DatabaseHelper();

  group('DatabaseHelper Tests', () {
    test('Insert and retrieve cards', () async {
      // Insert a card
      final card = CardItem(
        title: 'Test Card',
        description: 'Test Description',
        name: 'Test Name',
      );
      await dbHelper.insertCard(card);

      // Retrieve cards
      final cards = await dbHelper.getCards();

      // Verify the card is in the database
      expect(cards.isNotEmpty, true);
      expect(cards.first.title, 'Test Card');
      expect(cards.first.description, 'Test Description');
      expect(cards.first.name, 'Test Name');
    });

    test('Delete a card', () async {
      // Insert a card
      final card = CardItem(
        title: 'Card to Delete',
        description: 'Description to Delete',
        name: 'Name to Delete',
      );
      final id = await dbHelper.insertCard(card);

      // Delete the card
      await dbHelper.deleteCard(id);

      // Retrieve cards
      final cards = await dbHelper.getCards();

      // Verify the card is no longer in the database
      expect(cards.any((c) => c.title == 'Card to Delete'), false);
    });
  });
}
