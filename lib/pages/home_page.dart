import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../services/add_card_flow_manager.dart';
import '../services/share_service.dart';
import '../widgets/card_list_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/home_app_bar.dart';
import 'card_detail_page.dart';
import 'edit_card_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final List<CardItem> cards;
  final Function(CardItem) onAddCard;
  final Function(CardItem)? onUpdateCard;

  const HomePage({
    super.key,
    required this.cards,
    required this.onAddCard,
    this.onUpdateCard,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _navigateToAddCardPage() async {
    final newCard = await AddCardFlowManager.showAddCardFlow(
      context,
      useBottomSheet: true,
    );
    if (newCard != null) {
      final nextOrder = await _dbHelper.getNextSortOrder();
      final finalCard = CardItem(
        title: newCard.title,
        description: newCard.description,
        name: newCard.name,
        cardType: newCard.cardType,
        createdAt: newCard.createdAt,
        sortOrder: nextOrder,
        logoPath: newCard.logoPath,
      );
      await _dbHelper.insertCard(finalCard);
      final cards = await _dbHelper.getCards();
      setState(() {
        _displayedCards = cards;
      });
    }
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();
  late List<CardItem> _displayedCards;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _displayedCards = List.from(widget.cards);
    _applySearchFilter();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty && _searchQuery.isNotEmpty) {
        setState(() {
          _searchQuery = '';
          _applySearchFilter();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards != oldWidget.cards) {
      setState(() {
        _displayedCards = List.from(widget.cards);
        _applySearchFilter();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearchFilter() {
    List<CardItem> filteredCards = List.from(widget.cards);
    if (_searchQuery.isNotEmpty) {
      filteredCards =
          filteredCards.where((card) {
            return card.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();
    }
    setState(() {
      _displayedCards = filteredCards;
    });
  }

  void _onCardTap(CardItem card) async {
    final updated = await Navigator.push<CardItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => CardDetailPage(
              card: card,
              onDelete: (deletedCard) async {
                if (deletedCard.id != null) {
                  await _dbHelper.deleteCard(deletedCard.id!);
                }
                setState(() {
                  _displayedCards.removeWhere((c) => c.id == deletedCard.id);
                });
                final deleteSignal = CardItem(
                  title: "##DELETE_CARD_SIGNAL##",
                  description: "",
                  name: "",
                  cardType: CardType.qrCode,
                  sortOrder: -1,
                );
                widget.onAddCard(deleteSignal);
              },
            ),
      ),
    );
    if (updated != null && updated.id != null) {
      await _dbHelper.updateCard(updated);
      final cards = await _dbHelper.getCards();
      setState(() {
        _displayedCards = cards;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final CardItem item = _displayedCards.removeAt(oldIndex);
      _displayedCards.insert(newIndex, item);
      List<CardItem> cardsToUpdate = [];
      for (int i = 0; i < _displayedCards.length; i++) {
        if (_displayedCards[i].sortOrder != i) {
          cardsToUpdate.add(_displayedCards[i].copyWith(sortOrder: i));
        }
      }
      for (int i = 0; i < cardsToUpdate.length; i++) {
        int originalIndex = _displayedCards.indexWhere(
          (element) => element.id == cardsToUpdate[i].id,
        );
        if (originalIndex != -1) {
          _displayedCards[originalIndex] = cardsToUpdate[i];
        }
      }
      if (cardsToUpdate.isNotEmpty) {
        _dbHelper.updateCardSortOrders(cardsToUpdate);
      }
    });
  }

  List<Widget> _buildAppBarActions(AppLocalizations l10n) {
    return [
      IconButton(
        icon: const Icon(Icons.upload_file),
        tooltip: l10n.importCardsFromJsonTooltip,
        onPressed: () async {
          final typeGroup = XTypeGroup(label: 'json', extensions: ['json']);
          final file = await openFile(acceptedTypeGroups: [typeGroup]);
          if (file != null) {
            final content = await file.readAsString();
            try {
              final data = jsonDecode(content);
              if (data is Map<String, dynamic>) {
                final card = CardItem.fromMap(data);
                final nextOrder = await _dbHelper.getNextSortOrder();
                final newCard = card.copyWith(sortOrder: nextOrder);
                await _dbHelper.insertCard(newCard);
                widget.onAddCard(newCard);
              } else if (data is List) {
                for (final item in data) {
                  if (item is Map<String, dynamic>) {
                    final card = CardItem.fromMap(item);
                    final nextOrder = await _dbHelper.getNextSortOrder();
                    final newCard = card.copyWith(sortOrder: nextOrder);
                    await _dbHelper.insertCard(newCard);
                    widget.onAddCard(newCard);
                  }
                }
              }
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.importSuccessful)));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.invalidJsonFile)));
              }
            }
          }
        },
      ),
      if (_isSearchActive)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchController.clear();
              _searchQuery = '';
              _isSearchActive = false;
              _applySearchFilter();
            });
          },
        ),
      if (!_isSearchActive)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearchActive = true;
            });
          },
        ),
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Debug logging removed

    // Display a TextField in the AppBar when search mode is active so the
    // user can type queries directly. The HomeAppBar accepts an optional
    // titleWidget which we populate here.
    final titleWidget =
        _isSearchActive
            ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.search,
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                  _applySearchFilter();
                });
              },
            )
            : null;

    return Scaffold(
      appBar: HomeAppBar(
        l10n: l10n,
        actions: _buildAppBarActions(l10n),
        titleWidget: titleWidget,
      ),
      body:
          _displayedCards.isEmpty
              ? EmptyStateWidget(onAddCard: _navigateToAddCardPage)
              : CardListWidget(
                cards: _displayedCards,
                onCardTap: _onCardTap,
                onCardActions: (card) => _showCardActions(context, card, l10n),
                onReorder: _onReorder,
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCardPage,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 6.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ...existing code...
  // Use ShareService.shareCardAsImage to share a card consistently across the app.

  void _showCardActions(
    BuildContext context,
    CardItem card,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.editAction),
                onTap: () async {
                  Navigator.of(modalContext).pop();
                  final updated = await Navigator.push<CardItem>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCardPage(card: card),
                    ),
                  );

                  if (updated != null && updated.id != null) {
                    // Persist updated card and update UI
                    await _dbHelper.updateCard(updated);
                    if (widget.onUpdateCard != null) {
                      widget.onUpdateCard!(updated);
                    } else {
                      final index = _displayedCards.indexWhere(
                        (c) => c.id == updated.id,
                      );
                      if (index != -1) {
                        setState(() {
                          _displayedCards[index] = updated;
                        });
                      } else {
                        // If card not present locally, refresh list from DB
                        final cards = await _dbHelper.getCards();
                        setState(() {
                          _displayedCards = cards;
                        });
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(l10n.shareAsImageAction),
                onTap: () async {
                  Navigator.of(modalContext).pop(); // Close modal first
                  await ShareService.shareCardAsImageStatic(context, card);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
