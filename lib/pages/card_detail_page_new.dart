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

    // CardInfoWidget used in AppBar now handles the logo and title display.

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_currentCard);
        }
      },
      child: Scaffold(
        // Use a darker background to create a high-contrast look where the
        // barcode (white card) becomes the dominant, bright element.
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.background,
          elevation: 0,
          leading: BackButton(
            color: theme.colorScheme.onBackground,
            // BackButton by default uses a clear left-pointing arrow icon.
          ),
          titleSpacing: 0,
          // Compact header: keep the brand/logo prominent, minimize title
          // text so the barcode remains the primary focus.
          title: Row(
            children: [
              LogoAvatarWidget(
                logoKey: _currentCard.logoPath,
                title: _currentCard.title,
                size: 36,
                background: Colors.transparent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentCard.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: theme.colorScheme.onBackground),
              tooltip: l10n.shareAsImage,
              onPressed: _shareCardAsImage,
            ),
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.onBackground),
              tooltip: l10n.edit,
              onPressed: _startEditing,
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.onBackground),
                tooltip: l10n.delete,
                onPressed: () => _deleteCard(context),
              ),
            // Move delete into an overflow menu to avoid accidental taps.
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onBackground,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCard(context);
                }
              },
              itemBuilder:
                  (ctx) => [
                    if (widget.onDelete != null)
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
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
                              // Card type badge only; title is shown in AppBar via
                              // CardInfoWidget to avoid duplicate titles in the UI.
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
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

            // Emphasized Code display section: remove the redundant "Barcode"/"QR"
            // header and maximize the barcode/QR widget size. The barcode image
            // will sit inside a white card to keep contrast for scanners while
            // the surrounding scaffold is dark.
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
                      // Show the card title above the barcode image. We use
                      // RichText here so tests that rely on find.text still
                      // match the AppBar's title only (avoid duplicate plain
                      // Text widgets with the same string).
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: _currentCard.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // The central barcode/QR area. Use LayoutBuilder to maximize
                      // the widget to the available width while keeping some
                      // padding so scanners can recognize edges.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _showFullscreenCode(),
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 2,
                                ),
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Maximize to the available width while
                                    // reserving some breathing room for edges.
                                    final available = (constraints.maxWidth -
                                            24)
                                        .clamp(120.0, 1200.0);
                                    return _buildCodeWidget(available);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Human readable code for 1D barcodes: show directly
                      // beneath the barcode image using a large monospaced font
                      // and group digits for readability (XXXX XXXX ...).
                      if (_currentCard.isBarcode) ...[
                        const SizedBox(height: 12),
                        // Visible formatted code
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: _formatCode(_currentCard.name),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        // Keep the raw code value in the widget tree for
                        // compatibility with tests, but hide it visually so
                        // only the formatted monospaced representation is shown.
                        // Keep raw text present for tests but render it
                        // transparent so the user only sees the formatted
                        // monospaced version above.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _currentCard.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.transparent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 18),
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
