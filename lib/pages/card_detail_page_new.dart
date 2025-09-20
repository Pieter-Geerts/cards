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
import '../widgets/logo_avatar_widget.dart';

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
      MaterialPageRoute(
        builder:
            (context) => EditCardPage(
              card: _currentCard,
              onSave: (updatedCard) async {
                // Store navigator reference before async gap
                final navigator = Navigator.of(context);
                // Save the changes to the database
                await DatabaseHelper().updateCard(updatedCard);
                navigator.pop(updatedCard);
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
                      onPressed: _shareCardAsImage,
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

    // Use LogoAvatarWidget directly for logo rendering
    final logo = LogoAvatarWidget(
      logoKey: _currentCard.logoPath,
      title: _currentCard.title,
      size: 36,
      background: theme.colorScheme.surface,
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
              tooltip: l10n.shareAsImage,
              onPressed: _shareCardAsImage,
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
        body: CustomScrollView(
          slivers: [
            // Hero section - Card information
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Logo and title section
                          Row(
                            children: [
                              // Enhanced logo display
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.2,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: LogoAvatarWidget(
                                    logoKey: _currentCard.logoPath,
                                    title: _currentCard.title,
                                    size: 32,
                                    background: Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Title and card type
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentCard.title,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _currentCard.is2D
                                                ? theme
                                                    .colorScheme
                                                    .primaryContainer
                                                : theme
                                                    .colorScheme
                                                    .secondaryContainer,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _currentCard.is2D
                                            ? l10n.qrCode
                                            : l10n.barcode,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              _currentCard.is2D
                                                  ? theme
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                  : theme
                                                      .colorScheme
                                                      .onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Description section (if exists)
                          if (_currentCard.description.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 16,
                                        color: theme.colorScheme.onSurface
                                            .withAlpha(200),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface
                                              .withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currentCard.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurface,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Code display section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Code header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentCard.is2D
                                  ? Icons.qr_code_2
                                  : Icons.barcode_reader,
                              color: theme.colorScheme.onSurface.withAlpha(200),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _currentCard.is2D ? l10n.qrCode : l10n.barcode,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showFullscreenCode(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.fullscreen,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.scan,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Code display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _showFullscreenCode(),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    Colors
                                        .white, // Keep white for QR code scannability
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow.withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildCodeWidget(
                                280,
                              ), // Fixed optimal size
                            ),
                          ),
                        ),
                      ),

                      // Human readable code (for barcodes)
                      if (_currentCard.isBarcode) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  l10n.code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(200),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentCard.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
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
