import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';

import '../helpers/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/edit_card_page.dart';
import '../pages/home_page.dart' show buildLogoWidget;

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
  final GlobalKey _imageKey = GlobalKey();
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
      // Restore original brightness if we stored it
      if (_originalBrightness != null) {
        final screenBrightness = ScreenBrightness();
        await screenBrightness.setScreenBrightness(_originalBrightness!);
      }

      // Restore system UI
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

      debugPrint('Screen brightness restored to original level');
    } catch (e) {
      debugPrint('Failed to restore brightness: $e');
    }
  }

  void _startEditing() async {
    final updated = await Navigator.push<CardItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditCardPage(
              card: _currentCard,
              onSave: (updatedCard) async {
                // BUGFIX: Save to database first
                await DatabaseHelper().updateCard(updatedCard);
                Navigator.of(context).pop(updatedCard);
              },
            ),
      ),
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
        await DatabaseHelper().deleteCard(_currentCard.id!);

        // Check again if widget is still mounted after async operation
        if (!mounted) return;
      }

      widget.onDelete?.call(_currentCard);

      if (mounted) {
        navigator.pop();
      }
    }
  }

  Future<void> _shareCardAsImage() async {
    // Show the code widget in an overlay to render it offscreen
    final imageWidget = Material(
      type: MaterialType.transparency,
      child: Center(
        child: RepaintBoundary(
          key: _imageKey,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: _currentCard.renderForSharing(size: 320),
          ),
        ),
      ),
    );
    final overlay = OverlayEntry(builder: (_) => imageWidget);
    Overlay.of(context).insert(overlay);
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary =
          _imageKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final tempDir = await getTemporaryDirectory();
          final file =
              await File(
                '${tempDir.path}/card_${_currentCard.id ?? _currentCard.name}.png',
              ).create();
          await file.writeAsBytes(pngBytes);
          await Share.shareXFiles([XFile(file.path)], text: _currentCard.title);
        }
      }
    } finally {
      overlay.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final availableWidth = MediaQuery.of(context).size.width * 0.88;
    final logo = buildLogoWidget(
      _currentCard.logoPath,
      size: 36,
      background: theme.colorScheme.surface,
      title: _currentCard.title,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_currentCard);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: BackButton(color: theme.colorScheme.onSurface),
          titleSpacing: 0,
          title: Row(
            children: [
              if (_currentCard.logoPath != null &&
                  _currentCard.logoPath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: logo,
                ),
              Expanded(
                child: Text(
                  _currentCard.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
              tooltip: l10n.shareAsImage, // Changed from l10n.share
              onPressed: _shareCardAsImage, // Changed to call _shareCardAsImage
            ),
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.onSurface),
              tooltip: l10n.edit,
              onPressed: _startEditing,
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.onSurface),
                tooltip: l10n.delete,
                onPressed: () => _deleteCard(context),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Prominent White Card for Code ---
              Padding(
                padding: const EdgeInsets.only(
                  top: 36.0,
                  left: 20,
                  right: 20,
                  bottom: 0,
                ),
                child: Center(
                  child: Card(
                    color: Colors.white,
                    elevation: isDark ? 16 : 8,
                    shadowColor:
                        isDark
                            ? Colors.black.withAlpha(115) // 0.45 * 255 ≈ 115
                            : Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Container(
                      width: availableWidth,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 28,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barcode or QR code
                          _buildCodeWidget(availableWidth - 56),
                          const SizedBox(height: 18),
                          // Human-readable code value (only for barcodes, not QR codes)
                          if (_currentCard.isBarcode)
                            Text(
                              _currentCard.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                letterSpacing: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // --- Description/Notes Section ---
              if (_currentCard.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.description,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color:
                              isDark
                                  ? theme.colorScheme.onSurface.withAlpha(
                                    179,
                                  ) // 0.7 * 255 ≈ 179
                                  : Colors.grey[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentCard.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              isDark
                                  ? theme.colorScheme.onSurface.withAlpha(
                                    217,
                                  ) // 0.85 * 255 ≈ 217
                                  : Colors.grey[900],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeWidget(double availableWidth) {
    final size = _currentCard.is2D ? availableWidth * 0.7 : null;
    final width = _currentCard.is1D ? availableWidth * 0.8 : null;
    final height = _currentCard.is1D ? 90.0 : null;

    return _currentCard.renderCode(size: size, width: width, height: height);
  }
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
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
