import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../helpers/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../services/add_card_flow_manager.dart';
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
        tooltip: 'Import cards from JSON',
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
                ).showSnackBar(SnackBar(content: Text('Import successful!')));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Invalid JSON file.')));
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
    // Debug: Print logoPath for each card
    for (final card in _displayedCards) {
      // ignore: avoid_print
      print('Card: \'${card.title}\' logoPath: \'${card.logoPath}\'');
    }

    return Scaffold(
      appBar: HomeAppBar(l10n: l10n, actions: _buildAppBarActions(l10n)),
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
  Future<void> _shareCardAsImage(CardItem card) async {
    final boundaryKey = GlobalKey();
    final isQr = card.isQrCode;
    final imageWidget = Material(
      type: MaterialType.transparency,
      child: Center(
        child: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(24),
            child:
                isQr
                    ? QrImageView(
                      data: card.name,
                      size: 320,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      eyeStyle: const QrEyeStyle(color: Colors.black), // Added
                      dataModuleStyle: const QrDataModuleStyle(
                        color: Colors.black,
                      ),
                    )
                    : BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: card.name,
                      width: 320,
                      height: 120,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      color: Theme.of(context).colorScheme.onSurface,
                      drawText: false,
                    ),
          ),
        ),
      ),
    );
    final overlay = OverlayEntry(builder: (_) => imageWidget);
    Overlay.of(context).insert(overlay);
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final file =
              await File(
                '${tempDir.path}/card_${card.id ?? card.name}.png',
              ).create();
          await file.writeAsBytes(pngBytes);
          await Share.shareXFiles([XFile(file.path)], text: card.title);
        }
      }
    } finally {
      overlay.remove();
    }
  }

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
                  await Navigator.push<CardItem>(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditCardPage(
                            card: card,
                            onSave: (updated) async {
                              await _dbHelper.updateCard(updated);
                              // Use update callback instead of add callback
                              if (widget.onUpdateCard != null) {
                                widget.onUpdateCard!(updated);
                              } else {
                                // Fallback: update the local list
                                setState(() {
                                  final index = _displayedCards.indexWhere(
                                    (c) => c.id == updated.id,
                                  );
                                  if (index != -1) {
                                    _displayedCards[index] = updated;
                                  }
                                });
                              }
                            },
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(l10n.shareAsImageAction),
                onTap: () async {
                  Navigator.of(modalContext).pop(); // Close modal first
                  await _shareCardAsImage(card);
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
