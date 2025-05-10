import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../helpers/database_helper.dart';
import '../models/card_item.dart';
import 'add_card_page.dart';
import 'card_detail_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final List<CardItem> cards;
  final Function(CardItem) onAddCard;

  const HomePage({super.key, required this.cards, required this.onAddCard});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late List<CardItem> _cards;

  @override
  void initState() {
    super.initState();
    _cards = widget.cards;
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards != oldWidget.cards) {
      setState(() {
        _cards = widget.cards;
      });
    }
  }

  Future<void> _deleteCard(CardItem card) async {
    if (card.id != null) {
      await _dbHelper.deleteCard(card.id!);
      setState(() {
        _cards.removeWhere((item) => item.id == card.id);
      });
    }
  }

  void _onCardTap(CardItem card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailPage(card: card, onDelete: _deleteCard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCards),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body:
          _cards.isEmpty
              ? Center(child: Text(l10n.noCardsYet))
              : ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return ListTile(
                    title: Text(card.title),
                    subtitle: Text(card.description),
                    onTap: () => _onCardTap(card),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCardPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddCardPage() async {
    final newCard = await Navigator.push<CardItem>(
      context,
      MaterialPageRoute(builder: (_) => const AddCardPage()),
    );
    if (newCard != null) {
      widget.onAddCard(newCard);
    }
  }
}
