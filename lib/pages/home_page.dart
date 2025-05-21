import 'dart:convert';

import 'package:file_selector/file_selector.dart';
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
  // _originalCards will now be the source of truth, fetched ordered by sortOrder
  late List<CardItem> _displayedCards; // This list will be reorderable

  // SortOption _currentSortOption = SortOption.dateNewest; // Remove
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize with widget.cards, which should be loaded sorted by sortOrder from main.dart
    _displayedCards = List.from(widget.cards);
    _applySearchFilter(); // Apply initial search filter (if any)

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
        // Assuming widget.cards is always the full list, sorted by sortOrder
        _displayedCards = List.from(widget.cards);
        _applySearchFilter(); // Re-apply search filter
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearchFilter() {
    List<CardItem> filteredCards = List.from(
      widget.cards,
    ); // Start with the full, sorted list

    if (_searchQuery.isNotEmpty) {
      filteredCards =
          filteredCards.where((card) {
            return card.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();
    }
    // No explicit sort here, as the list from widget.cards is already sorted by sortOrder
    // and ReorderableListView handles visual reordering.
    setState(() {
      _displayedCards = filteredCards;
    });
  }

  Future<void> _deleteCard(CardItem card) async {
    if (card.id != null) {
      await _dbHelper.deleteCard(card.id!);
      // Use a very specific, unlikely-to-be-real card as a signal
      // to main.dart to reload the cards without inserting this one.
      // CardItem.temp creates a card with id=null and sortOrder=-1.
      widget.onAddCard(
        CardItem.temp(
          title: "##DELETE_CARD_SIGNAL##",
          description: "",
          name: "",
        ),
      );
    }
  }

  void _onCardTap(CardItem card) async {
    final updated = await Navigator.push<CardItem>(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailPage(card: card, onDelete: _deleteCard),
      ),
    );
    if (updated != null && updated.id != null) {
      // Update the card in the displayed list
      setState(() {
        final idx = _displayedCards.indexWhere((c) => c.id == updated.id);
        if (idx != -1) {
          _displayedCards[idx] = updated;
        }
      });
    }
  }

  Widget _buildAppBarTitle(AppLocalizations l10n) {
    if (_isSearchActive) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '${l10n.search}...', // Add search localization
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).appBarTheme.titleTextStyle?.color?.withOpacity(0.7),
          ),
        ),
        style: Theme.of(context).appBarTheme.titleTextStyle,
        onChanged: (query) {
          // For real-time search, enable this and remove listener logic if preferred
          // setState(() {
          //   _searchQuery = query;
          //   _applyFiltersAndSort();
          // });
        },
        onSubmitted: (query) {
          // Apply search on submit
          setState(() {
            _searchQuery = query;
            _applySearchFilter();
          });
        },
      );
    } else {
      return Text(l10n.myCards);
    }
  }

  List<Widget> _buildAppBarActions(AppLocalizations l10n) {
    return [
      IconButton(
        icon: const Icon(Icons.upload_file),
        tooltip: 'Import cards from JSON',
        onPressed: () async {
          final typeGroup = XTypeGroup(label: 'json', extensions: ['json']);
          final file = await openFile(acceptedTypeGroups: [typeGroup]);
          if (file != null) {
            final content = await file.readAsString();
            try {
              final data = jsonDecode(content);
              if (data is Map<String, dynamic>) {
                // Single card
                final card = CardItem.fromMap(data);
                final nextOrder = await _dbHelper.getNextSortOrder();
                final newCard = card.copyWith(sortOrder: nextOrder);
                await _dbHelper.insertCard(newCard);
                widget.onAddCard(newCard);
              } else if (data is List) {
                // Multiple cards
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Import successful!')));
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Invalid JSON file.')));
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
              // _isSearchActive = false; // Keep search active until explicitly closed or search submitted
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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final CardItem item = _displayedCards.removeAt(oldIndex);
      _displayedCards.insert(newIndex, item);

      // Update sortOrder for all displayed cards and persist
      List<CardItem> cardsToUpdate = [];
      for (int i = 0; i < _displayedCards.length; i++) {
        if (_displayedCards[i].sortOrder != i) {
          cardsToUpdate.add(_displayedCards[i].copyWith(sortOrder: i));
        }
      }
      // Update the _displayedCards with new sortOrder values for consistency
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
      // Also update the main list in main.dart if necessary, or rely on next full load.
      // For now, we assume the local _displayedCards is the primary view model for this screen.
      // And widget.cards will be updated on next full app load/reload from main.
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading:
            _isSearchActive
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = false;
                      _searchController.clear();
                      _searchQuery = '';
                      _applySearchFilter();
                    });
                  },
                )
                : null,
        title: _buildAppBarTitle(l10n),
        actions: _buildAppBarActions(l10n),
      ),
      body:
          _displayedCards.isEmpty
              ? Center(
                child: Text(
                  _searchQuery.isNotEmpty
                      ? '${l10n.noResultsFound} "$_searchQuery"'
                      : l10n.noCardsYet,
                ),
              )
              : ReorderableListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _displayedCards.length,
                itemBuilder: (context, index) {
                  final card = _displayedCards[index];
                  return Container(
                    key: ValueKey(
                      card.id ?? card.name + card.createdAt.toString(),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 8.0,
                    ),
                    child: Material(
                      elevation: 6.0,
                      borderRadius: BorderRadius.circular(18.0),
                      color: Theme.of(context).cardColor,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : null, // Use a light shadow in dark mode
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18.0),
                        onTap: () => _onCardTap(card),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 28.0,
                            horizontal: 24.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.title.toUpperCase(),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Only show description if it's not empty
                              if (card.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  card.description,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onReorder: _onReorder,
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCardPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToAddCardPage() async {
    final tempCardData = await Navigator.push<CardItem>(
      // Expecting CardItem.temp
      context,
      MaterialPageRoute(builder: (_) => const AddCardPage()),
    );
    if (tempCardData != null) {
      final nextOrder = await _dbHelper.getNextSortOrder();
      final newCard = CardItem(
        title: tempCardData.title,
        description: tempCardData.description,
        name: tempCardData.name,
        cardType: tempCardData.cardType,
        createdAt: tempCardData.createdAt, // Use createdAt from temp card
        sortOrder: nextOrder,
      );
      widget.onAddCard(
        newCard,
      ); // This will trigger a reload in main.dart and update widget.cards
    }
  }
}
