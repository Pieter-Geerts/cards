import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/card_item.dart';
import '../utils/simple_icons_mapping.dart';
import 'i_database_helper.dart';

class DatabaseHelper implements IDatabaseHelper {
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
      version: 5, // Increment version to 5
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            name TEXT,
            cardType TEXT,
            createdAt INTEGER,
            sortOrder INTEGER,
            logoPath TEXT
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
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE cards ADD COLUMN logoPath TEXT');
        }
      },
    );
  }

  @override
  Future<int> insertCard(CardItem card) async {
    final db = await database;
    // The card object passed here should already have its sortOrder set.
    // If sortOrder is determined by MAX(sortOrder)+1, it should be done before calling this.
    return db.insert('cards', card.toMap());
  }

  @override
  Future<List<CardItem>> getCards() async {
    final db = await database;
    // Fetch cards ordered by their sortOrder
    final maps = await db.query('cards', orderBy: 'sortOrder ASC');
    return List.generate(maps.length, (i) => CardItem.fromMap(maps[i]));
  }

  @override
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

  @override
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

  @override
  Future<int> deleteCard(int id) async {
    final db = await database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }

  @override
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

  @override
  Future<void> deleteAllCards() async {
    final db = await database;
    await db.delete('cards');
  }

  @override
  Future<CardItem?> getCard(int id) async {
    final db = await database;
    final maps = await db.query('cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return CardItem.fromMap(maps.first);
    }
    return null;
  }

  /// Dev helper: attempt to backfill `logoPath` for existing cards by
  /// matching the card title against known SimpleIcons identifiers.
  /// Returns the number of rows updated. This should be run manually
  /// during a migration step or from a debug console.
  @override
  Future<int> backfillLogoPathsFromTitles({bool dryRun = true}) async {
    final db = await database;
    final cards = await db.query('cards', columns: ['id', 'title', 'logoPath']);
    int updated = 0;

    for (final row in cards) {
      final id = row['id'] as int?;
      final title = (row['title'] as String?)?.toLowerCase() ?? '';
      final existing = row['logoPath'] as String?;

      if (id == null) continue;
      if (existing != null && existing.isNotEmpty) continue; // already set

      String? matchedIdentifier;
      // Try simple substring matching against known identifiers / keys
      for (final entry in SimpleIconsMapping.iconToIdentifier.entries) {
        final identifier = entry.value; // e.g. 'simple_icon:albertheijn'
        final key = identifier.replaceFirst('simple_icon:', '').toLowerCase();
        if (title.contains(key)) {
          matchedIdentifier = identifier;
          break;
        }
      }

      if (matchedIdentifier != null) {
        if (!dryRun) {
          await db.update(
            'cards',
            {'logoPath': matchedIdentifier},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
        updated++;
      }
    }

    return updated;
  }
}
