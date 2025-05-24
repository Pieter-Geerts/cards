import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      setState(() {
        final idx = _displayedCards.indexWhere((c) => c.id == updated.id);
        if (idx != -1) {
          _displayedCards[idx] = updated;
        }
      });
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
      // Also update the main list in main.dart if necessary, or rely on next full load/reload from main.
      // For now, we assume the local _displayedCards is the primary view model for this screen.
      // And widget.cards will be updated on next full app load/reload from main.
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(l10n.myCards),
        ),
        actions: _buildAppBarActions(l10n),
        elevation: 4.0, // More pronounced shadow
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
          size: 28,
        ),
        toolbarHeight: 64,
      ),
      body:
          _displayedCards.isEmpty
              ? _buildEmptyState(context, l10n)
              : ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 12.0,
                ),
                itemCount: _displayedCards.length,
                itemBuilder: (context, index) {
                  final card = _displayedCards[index];
                  return Container(
                    key: ValueKey(
                      card.id ?? card.name + card.createdAt.toString(),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Material(
                      elevation: 8.0, // More pronounced elevation
                      borderRadius: BorderRadius.circular(
                        20.0,
                      ), // Consistent rounded corners
                      color: Theme.of(context).cardColor,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.black26,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () => _onCardTap(card),
                        splashColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.12),
                        highlightColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.08),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 28.0,
                            horizontal: 24.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildLogoWidget(card.logoPath),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (card.description.trim().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        card.description,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                onSelected: (value) async {
                                  if (value == 'edit') _onCardTap(card);
                                  // Do not handle delete here
                                },
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Builder(
                                          builder:
                                              (menuContext) => ListTile(
                                                title: Text(l10n.delete),
                                                onTap: () async {
                                                  Navigator.of(
                                                    menuContext,
                                                  ).pop(); // Close the menu
                                                  await Future.delayed(
                                                    const Duration(
                                                      milliseconds: 100,
                                                    ),
                                                  );
                                                  _deleteCard(card);
                                                },
                                              ),
                                        ),
                                      ),
                                    ],
                              ),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add, size: 32),
        elevation: 6.0,
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCardsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToAddCardPage,
              icon: const Icon(Icons.add),
              label: Text(l10n.addCard),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                textStyle: Theme.of(context).textTheme.titleMedium,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
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
        logoPath: tempCardData.logoPath, // <-- Ensure logoPath is passed!
      );
      widget.onAddCard(
        newCard,
      ); // This will trigger a reload in main.dart and update widget.cards
    }
  }
}

// Place this in a shared file for reuse, but for now, define here for all pages
Widget buildLogoWidget(
  String? logoPath, {
  double size = 48,
  Color? background,
}) {
  final theme =
      WidgetsBinding
                  .instance
                  .platformDispatcher
                  .views
                  .first
                  .platformDispatcher
                  .defaultRouteName ==
              '/'
          ? null
          : Theme.of(
            WidgetsBinding.instance.focusManager.primaryFocus?.context ??
                WidgetsBinding
                        .instance
                        .platformDispatcher
                        .views
                        .first
                        .platformDispatcher
                        .defaultRouteName
                    as BuildContext,
          );
  final bgColor = background ?? (theme?.colorScheme.surface ?? Colors.white);
  if (logoPath != null && logoPath.isNotEmpty) {
    final file = File(logoPath);
    final exists = file.existsSync();
    if (exists) {
      if (logoPath.toLowerCase().endsWith('.svg')) {
        return CircleAvatar(
          backgroundColor: bgColor,
          radius: size / 2,
          child: ClipOval(
            child: SvgPicture.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        return CircleAvatar(
          backgroundColor: bgColor,
          radius: size / 2,
          backgroundImage: FileImage(file),
        );
      }
    }
  }
  return CircleAvatar(
    backgroundColor: bgColor,
    radius: size / 2,
    child: Icon(
      Icons.credit_card,
      size: size * 0.6,
      color: theme?.colorScheme.onSurface ?? Colors.black,
    ),
  );
}
