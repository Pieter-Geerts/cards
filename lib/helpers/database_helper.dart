import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/card_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cards.db');

    return openDatabase(
      path,
      version: 4, // Increment version to 4
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            name TEXT,
            cardType TEXT,
            createdAt INTEGER,
            sortOrder INTEGER 
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE cards ADD COLUMN cardType TEXT DEFAULT "QR_CODE"',
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE cards ADD COLUMN createdAt INTEGER DEFAULT ${DateTime.now().millisecondsSinceEpoch}',
          );
        }
        if (oldVersion < 4) {
          // Add sortOrder column and initialize it (e.g., based on creation time or ID)
          await db.execute('ALTER TABLE cards ADD COLUMN sortOrder INTEGER');
          // Initialize sortOrder for existing records, e.g., by createdAt or id
          // This ensures existing cards have a defined order.
          // Using id as a simple initial sort order.
          List<Map<String, dynamic>> existingCards = await db.query(
            'cards',
            columns: ['id'],
          );
          Batch batch = db.batch();
          for (int i = 0; i < existingCards.length; i++) {
            batch.update(
              'cards',
              {'sortOrder': existingCards[i]['id']},
              where: 'id = ?',
              whereArgs: [existingCards[i]['id']],
            );
          }
          await batch.commit(noResult: true);
        }
      },
    );
  }

  Future<int> insertCard(CardItem card) async {
    final db = await database;
    // The card object passed here should already have its sortOrder set.
    // If sortOrder is determined by MAX(sortOrder)+1, it should be done before calling this.
    return db.insert('cards', card.toMap());
  }

  Future<List<CardItem>> getCards() async {
    final db = await database;
    // Fetch cards ordered by their sortOrder
    final maps = await db.query('cards', orderBy: 'sortOrder ASC');
    return List.generate(maps.length, (i) => CardItem.fromMap(maps[i]));
  }

  Future<int> getNextSortOrder() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(sortOrder) as maxOrder FROM cards',
    );
    final maxOrder = result.first['maxOrder'];
    if (maxOrder != null && maxOrder is int) {
      return maxOrder + 1;
    }
    return 0; // If no cards, start with 0
  }

  Future<void> updateCardSortOrders(List<CardItem> cards) async {
    final db = await database;
    Batch batch = db.batch();
    for (var card in cards) {
      if (card.id != null) {
        batch.update(
          'cards',
          {'sortOrder': card.sortOrder},
          where: 'id = ?',
          whereArgs: [card.id],
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<int> deleteCard(int id) async {
    final db = await database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCard(CardItem card) async {
    final db = await database;
    if (card.id == null) return 0;
    return db.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }
}
