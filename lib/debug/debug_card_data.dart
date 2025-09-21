// ignore_for_file: library_private_types_in_public_api
// Debug helper to check what data is in cards
import 'package:cards/helpers/database_helper.dart';
import 'package:cards/models/card_item.dart';
import 'package:flutter/material.dart';

class DebugCardData extends StatefulWidget {
  const DebugCardData({super.key});

  @override
  _DebugCardDataState createState() => _DebugCardDataState();
}

class _DebugCardDataState extends State<DebugCardData> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug Card Data')),
      body: ListView.builder(
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return Card(
            child: ListTile(
              title: Text(card.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${card.id}'),
                  Text('Description: ${card.description}'),
                  Text('LogoPath: ${card.logoPath ?? 'NULL'}'),
                  Text('CardType: ${card.cardType}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
