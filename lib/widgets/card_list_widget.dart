import 'package:flutter/material.dart';

import '../models/card_item.dart';
import 'card_item_widget.dart';

class CardListWidget extends StatelessWidget {
  final List<CardItem> cards;
  final void Function(CardItem) onCardTap;
  final void Function(CardItem) onCardActions;
  final void Function(int, int) onReorder;
  final bool canReorder;

  const CardListWidget({
    super.key,
    required this.cards,
    required this.onCardTap,
    required this.onCardActions,
    required this.onReorder,
    this.canReorder = true,
  });

  Widget _buildCard(BuildContext context, int index) {
    final card = cards[index];
    return CardItemWidget(
      key: ValueKey(card.id ?? card.name + card.createdAt.toString()),
      card: card,
      onTap: () => onCardTap(card),
      onActions: () => onCardActions(card),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!canReorder) {
      return ListView.builder(
        key: const ValueKey('card_list'),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        itemCount: cards.length,
        itemBuilder: _buildCard,
      );
    }

    return ReorderableListView.builder(
      key: const ValueKey('card_list'),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      itemCount: cards.length,
      itemBuilder: _buildCard,
      onReorder: onReorder,
    );
  }
}
