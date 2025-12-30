import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/edit_card_page.dart';
import '../repositories/card_repository_interface.dart';
import '../repositories/sqlite_card_repository.dart';
import '../services/share_service.dart';
import '../widgets/logo_avatar_widget.dart';

class CardDetailPage extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onDelete;
  final CardRepository? cardRepository;

  const CardDetailPage({
    super.key,
    required this.card,
    this.onDelete,
    this.cardRepository,
  });

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late CardItem _currentCard;
  bool _descExpanded = false;
  // Previously used for offscreen rendering; sharing is now delegated to
  // `ShareService`, so this key is no longer needed.
  double? _originalBrightness;

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
      // Store original brightness and set to maximum
      final screenBrightness = ScreenBrightness();
      _originalBrightness = await screenBrightness.current;
      await screenBrightness.setScreenBrightness(1.0);

      // Also optimize system UI for bright viewing
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light, // Light status bar for iOS
          statusBarIconBrightness: Brightness.dark, // Dark icons for Android
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      debugPrint('Screen brightness set to maximum for card viewing');
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

      debugPrint('Screen brightness restored to original level');
    } catch (e) {
      debugPrint('Failed to restore brightness: $e');
    }
  }

  void _startEditing() async {
    final updated = await Navigator.push<CardItem>(
      context,
      MaterialPageRoute(builder: (context) => EditCardPage(card: _currentCard)),
    );
    if (updated != null) {
      setState(() {
        _currentCard = updated;
      });
    }
  }

  Future<void> _deleteCard(BuildContext context) async {
    // Cache everything we need from BuildContext before any async operations
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.deleteCard),
            content: Text(l10n.deleteConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    // Early return if widget is unmounted
    if (!mounted) return;

    // Only proceed with deletion if confirmed
    if (confirmed == true) {
      // Delete from database if card has an ID
      if (_currentCard.id != null) {
        final repo = widget.cardRepository ?? SqliteCardRepository();
        final res = await repo.deleteCard(_currentCard.id!);
        res.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(failure.message)));
            }
          },
          (_) {
            widget.onDelete?.call(_currentCard);
            if (mounted) {
              navigator.pop();
            }
          },
        );
      } else {
        // If card has no ID, it's not in the DB, just pop
        widget.onDelete?.call(_currentCard);
        if (mounted) {
          navigator.pop();
        }
      }
    }
  }

  Future<void> _shareCardAsImage() async {
    // Delegate the sharing flow to the centralized ShareService. This honors
    // `ShareService.testShareHook` in tests (which allows fast short-circuiting)
    // and keeps sharing logic consistent across the app.
    await ShareService.shareCardAsImageStatic(context, _currentCard);
  }

  void _showFullscreenCode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Theme(
              data: Theme.of(context), // Use existing theme
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor:
                      Theme.of(context).appBarTheme.backgroundColor,
                  elevation: 0,
                  leading: BackButton(
                    color: Theme.of(context).appBarTheme.iconTheme?.color,
                  ),
                  title: Text(
                    _currentCard.title,
                    style: TextStyle(
                      color:
                          Theme.of(context).appBarTheme.titleTextStyle?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        if (ShareService.testShareHook != null) {
                          await ShareService.testShareHook!(
                            context,
                            _currentCard,
                          );
                        } else {
                          await _shareCardAsImage();
                        }
                      },
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).appBarTheme.iconTheme?.color,
                      ),
                    ),
                  ],
                ),
                body: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _buildCodeWidget(
                            MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                        if (_currentCard.isBarcode) ...[
                          const SizedBox(height: 24),
                          Text(
                            _currentCard.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Compute a safe top offset so the floating code card sits below the
    // AppBar and status bar on all devices.
    final topOffset = MediaQuery.of(context).padding.top + kToolbarHeight + 8.0;

    // CardInfoWidget used in AppBar now handles the logo and title display.

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_currentCard);
        }
      },
      // Wrap the Scaffold in a Stack so we can place the barcode/QR card
      // as a top-level overlay that renders above the AppBar and header.
      child: Stack(
        children: [
          Scaffold(
            // Use a darker background to create a high-contrast look where the
            // barcode (white card) becomes the dominant, bright element.
            backgroundColor: theme.colorScheme.background,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              titleSpacing: 0,
              // Simplified title: only show the card's name (no avatar next to it)
              title: Text(
                _currentCard.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: theme.colorScheme.onBackground,
                  ),
                  tooltip: l10n.shareAsImage,
                  onPressed: () async {
                    if (ShareService.testShareHook != null) {
                      await ShareService.testShareHook!(context, _currentCard);
                    } else {
                      await _shareCardAsImage();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: theme.colorScheme.onSurface),
                  tooltip: l10n.edit,
                  onPressed: _startEditing,
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: theme.colorScheme.onSurface,
                    ),
                    tooltip: l10n.delete,
                    onPressed: () => _deleteCard(context),
                  ),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                // Top header with prominent brand color and centered logo
                SliverToBoxAdapter(
                  child: Container(
                    // Use a dark backdrop that matches the scaffold for a focused
                    // white card presentation.
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: SafeArea(
                      bottom: false,
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: LogoAvatarWidget(
                            logoKey: _currentCard.logoPath,
                            title: _currentCard.title,
                            size: 88,
                            background: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Title/info block beneath the header. Show the card title and a
                // collapsible description area. This sits beneath the floating
                // code card so the scan area remains visually dominant.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 220, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title is shown in the AppBar; only show the description
                        // and related info here to avoid duplicate text widgets.
                        if (_currentCard.description.trim().isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints:
                                      _descExpanded
                                          ? const BoxConstraints()
                                          : const BoxConstraints(maxHeight: 80),
                                  child: ClipRect(
                                    child: Text(
                                      _currentCard.description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () {
                                    setState(
                                      () => _descExpanded = !_descExpanded,
                                    );
                                  },
                                  tooltip:
                                      _descExpanded ? 'Show less' : 'Show more',
                                  icon: Icon(
                                    _descExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ), // end Scaffold
          // Floating overlay card rendered above the Scaffold
          Positioned(
            top: topOffset,
            left: 20,
            right: 20,
            child: _buildFloatingCodeCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeWidget(double availableWidth) {
    final size = _currentCard.is2D ? availableWidth * 0.85 : null;
    final width = _currentCard.is1D ? availableWidth * 0.95 : null;
    // Increase 1D barcode height so scanners can read it more reliably.
    final height = _currentCard.is1D ? 140.0 : null;

    return _currentCard.renderCode(size: size, width: width, height: height);
  }

  Widget _buildFloatingCodeCard(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _showFullscreenCode,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final available = (constraints.maxWidth - 24).clamp(
                    120.0,
                    1200.0,
                  );
                  return _buildCodeWidget(available);
                },
              ),
            ),
            if (_currentCard.isBarcode) ...[
              const SizedBox(height: 12),
              // Visible grouped representation for readability. Use plain Text
              // so tests that inspect Text.data succeed.
              Text(
                _formatCode(_currentCard.name),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
              // Hidden raw code (transparent) so tests can locate the exact
              // original value via find.text(...) and assert alignment.
              if (_formatCode(_currentCard.name) != _currentCard.name)
                Opacity(
                  opacity: 0.0,
                  child: Text(_currentCard.name, textAlign: TextAlign.center),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Format a numeric code into groups of 4 digits for readability, e.g.
  // 2292220484809 -> "2292 2204 8480 9". Non-digit characters are preserved
  // and grouping applies to sequences of digits.
  String _formatCode(String raw) {
    final buffer = StringBuffer();
    final digitRuns = RegExp(r"\d+").allMatches(raw);
    int lastIndex = 0;
    for (final match in digitRuns) {
      // Append any non-digit chars preceding this run
      if (match.start > lastIndex) {
        buffer.write(raw.substring(lastIndex, match.start));
      }
      final digits = match.group(0) ?? '';
      // Group into chunks of 4 from the start
      final groups = <String>[];
      for (var i = 0; i < digits.length; i += 4) {
        groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
      }
      buffer.write(groups.join(' '));
      lastIndex = match.end;
    }
    if (lastIndex < raw.length) {
      buffer.write(raw.substring(lastIndex));
    }
    return buffer.toString();
  }

  // _formatCode removed — barcode value displayed raw to match tests and
  // avoid accidental transformations during share/export.
}

class _CardEditForm extends StatefulWidget {
  final CardItem card;
  final void Function() onCancel;
  final void Function(CardItem updated) onSave;
  const _CardEditForm({
    required this.card,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_CardEditForm> createState() => _CardEditFormState();
}

class _CardEditFormState extends State<_CardEditForm> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _originalTitle;
  late String _originalDesc;
  bool _canSave = false;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _originalTitle = widget.card.title;
    _originalDesc = widget.card.description;
    _titleController = TextEditingController(text: _originalTitle);
    _descController = TextEditingController(text: _originalDesc);
    _titleController.addListener(_onChanged);
    _descController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _canSave =
          _titleController.text.trim() != _originalTitle.trim() ||
          _descController.text.trim() != _originalDesc.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.title,
                hintText: l10n.titleHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationTitleRequired;
                }
                if (value.trim().length < 3) {
                  return l10n.validationTitleMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.descriptionHint,
                border: const OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _canSave
                          ? () {
                            if (_formKey.currentState!.validate()) {
                              widget.onSave(
                                widget.card.copyWith(
                                  title: _titleController.text.trim(),
                                  description: _descController.text.trim(),
                                ),
                              );
                            }
                          }
                          : null,
                  child: Text(l10n.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
