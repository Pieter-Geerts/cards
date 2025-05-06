import 'package:flutter/material.dart';

import '../models/card_item.dart';
import 'add_card_page.dart';
import 'card_detail_page.dart';

class HomePage extends StatelessWidget {
  final List<CardItem> cards;
  final void Function(CardItem) onAddCard;

  const HomePage({super.key, required this.cards, required this.onAddCard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            child: ListTile(
              title: Text(card.title),
              subtitle: Text(card.description),
              trailing: Text(card.name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newCard = await Navigator.push<CardItem>(
            context,
            MaterialPageRoute(builder: (_) => AddCardPage()),
          );
          if (newCard != null) {
            onAddCard(newCard);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
