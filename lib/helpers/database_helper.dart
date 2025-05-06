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
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            name TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertCard(CardItem card) async {
    final db = await database;
    return db.insert('cards', card.toMap());
  }

  Future<List<CardItem>> getCards() async {
    final db = await database;
    final maps = await db.query('cards');
    return List.generate(maps.length, (i) => CardItem.fromMap(maps[i]));
  }

  Future<int> deleteCard(int id) async {
    final db = await database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
