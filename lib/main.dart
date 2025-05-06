import 'package:flutter/material.dart';

import 'helpers/database_helper.dart';
import 'models/card_item.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<CardItem> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _dbHelper.getCards();
    setState(() {
      _cards = cards;
    });
  }

  Future<void> _addCard(CardItem card) async {
    await _dbHelper.insertCard(card);
    _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(cards: _cards, onAddCard: _addCard),
    );
  }
}
