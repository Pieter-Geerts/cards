import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../widgets/card_code_widget.dart';
import '../widgets/card_info_widget.dart';
import '../widgets/card_notes_widget.dart';
import 'edit_card_page.dart';

class CardDetailPage extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onDelete;

  const CardDetailPage({super.key, required this.card, this.onDelete});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late CardItem _currentCard;
  double? _originalBrightness;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _titleController = TextEditingController(text: _currentCard.title);
    _descController = TextEditingController(text: _currentCard.description);
    _setBrightnessToMax();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _restoreOriginalBrightness();
    super.dispose();
  }

  Future<void> _setBrightnessToMax() async {
    try {
      final screenBrightness = ScreenBrightness();
      _originalBrightness = await screenBrightness.current;
      await screenBrightness.setScreenBrightness(1.0);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } catch (e) {
      debugPrint('Failed to set brightness: $e');
    }
  }

  Future<void> _restoreOriginalBrightness() async {
    try {
      if (_originalBrightness != null) {
        final screenBrightness = ScreenBrightness();
        await screenBrightness.setScreenBrightness(_originalBrightness!);
      }
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } catch (e) {
      debugPrint('Failed to restore brightness: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: CardInfoWidget(card: _currentCard),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.share,
            onPressed: () {
              Share.share(_currentCard.name, subject: _currentCard.title);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.edit,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => EditCardPage(
                        card: _currentCard,
                        onSave: (updatedCard) {
                          setState(() {
                            _currentCard = updatedCard;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                ),
              );
            },
          ),
          if (widget.onDelete != null)
            _isProcessing
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    width: 48,
                    height: kToolbarHeight,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                : IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.delete,
                  onPressed: () async {
                    // Capture NavigatorState before awaiting to avoid using BuildContext across async gaps
                    final navigator = Navigator.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text(l10n.deleteCard),
                            content: Text(l10n.deleteConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => navigator.pop(false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => navigator.pop(true),
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      setState(() {
                        _isProcessing = true;
                      });
                      try {
                        final result = widget.onDelete!(_currentCard);
                        if (result is Future) {
                          await result;
                        }
                      } catch (e) {
                        debugPrint('Error while deleting card: $e');
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isProcessing = false;
                          });
                          // Use captured navigator to pop the detail page
                          navigator.pop();
                        }
                      }
                    }
                  },
                ),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: theme.colorScheme.surface,
                margin: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: CardCodeWidget(card: _currentCard),
                ),
              ),
              // Share button moved to app bar
              const SizedBox(height: 24),
              CardNotesWidget(card: _currentCard),
            ],
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
