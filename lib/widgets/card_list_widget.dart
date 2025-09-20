import 'package:flutter/material.dart';

import '../models/card_item.dart';
import 'card_item_widget.dart';

class CardListWidget extends StatelessWidget {
  final List<CardItem> cards;
  final void Function(CardItem) onCardTap;
  final void Function(CardItem) onCardActions;
  final void Function(int, int) onReorder;

  const CardListWidget({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.onCardActions,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return CardItemWidget(
          key: ValueKey(card.id ?? card.name + card.createdAt.toString()),
          card: card,
          onTap: () => onCardTap(card),
          onActions: () => onCardActions(card),
        );
      },
      onReorder: onReorder,
    );
  }
}
