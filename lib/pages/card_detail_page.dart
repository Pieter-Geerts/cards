import 'package:flutter/material.dart';

import '../controllers/card_detail_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/edit_card_page.dart';
import '../services/share_service.dart';
import '../widgets/code_card_widget.dart';
import '../widgets/logo_avatar_widget.dart';

class CardDetailPage extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onDelete;
  final CardDetailController? controller;

  const CardDetailPage({
    super.key,
    required this.card,
    this.onDelete,
    this.controller,
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
  late CardDetailController _controller;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _titleController = TextEditingController(text: _currentCard.title);
    _descController = TextEditingController(text: _currentCard.description);
    // Create controller that owns non-UI responsibilities. Allow injection
    // for tests by using widget.controller when provided.
    _controller = widget.controller ?? CardDetailController(card: _currentCard);

    // Defer brightness change until after first frame so UI is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _controller.setBrightnessToMax();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _controller.restoreBrightness();
    super.dispose();
  }

  void _startEditing() async {
    final updated = await Navigator.push<CardItem>(
      context,
      MaterialPageRoute(builder: (context) => EditCardPage(card: _currentCard)),
    );
    if (updated != null) {
      if (!mounted) return;
      setState(() {
        _currentCard = updated;
      });
    }
  }

  Future<void> _deleteCard(BuildContext context) async {
    // Show confirmation dialog. Obtain localized strings inside the builder
    // so we don't capture the parent's BuildContext across the async boundary.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
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
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      try {
        await _controller.deleteCard();
      } catch (e, st) {
        debugPrint('Failed deleting card from DB: $e\n$st');
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
        return;
      }

      widget.onDelete?.call(_currentCard);

      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _shareCardAsImage() async {
    await _controller.shareAsImage(context);
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
                        CodeCardWidget(
                          card: _currentCard,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          maxHeight: MediaQuery.of(context).size.height * 0.55,
                          onTap: _showFullscreenCode,
                          showLogo: false, // show logo in header instead
                          logoOverlay: false,
                        ),
                        if (_currentCard.isBarcode) ...[
                          // Header with logo and title
                          if (_currentCard.logoPath != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                      child: Image.asset(
                                        _currentCard.logoPath!,
                                        fit: BoxFit.contain,
                                        width: 64,
                                        height: 64,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      _currentCard.title,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),

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

    // Put the logo and title above the code card (no overlay). This keeps
    // the code area on a dedicated white background and ensures it's visible
    // without being obscured by other UI chrome.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_currentCard);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          titleSpacing: 0,
          title: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: Icon(Icons.share, color: theme.colorScheme.onBackground),
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
                icon: Icon(Icons.delete, color: theme.colorScheme.onSurface),
                tooltip: l10n.delete,
                onPressed: () => _deleteCard(context),
              ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            // Top header with centered logo
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title above the logo. Increase font size so it visually
                          // balances the logo.
                          Text(
                            _currentCard.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          LogoAvatarWidget(
                            logoKey: _currentCard.logoPath,
                            title: _currentCard.title,
                            size: 88,
                            background: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Code card placed directly under the logo so it is always visible
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double maxWidth = constraints.maxWidth * 0.95;
                      if (maxWidth > 720) maxWidth = 720;
                      final maxHeight =
                          MediaQuery.of(context).size.height * 0.45;
                      return CodeCardWidget(
                        card: _currentCard,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight,
                        onTap: _showFullscreenCode,
                        showLogo: false,
                        logoOverlay: false,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Title/info block beneath the code card. Show collapsible description
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                setState(() => _descExpanded = !_descExpanded);
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
      ),
    );
  }

  // Widget _buildCodeWidget(double availableWidth) {
  //   final size = _currentCard.is2D ? availableWidth * 0.85 : null;
  //   final width = _currentCard.is1D ? availableWidth * 0.95 : null;
  //   // Increase 1D barcode height so scanners can read it more reliably.
  //   final height = _currentCard.is1D ? 140.0 : null;

  //   return _currentCard.renderCode(size: size, width: width, height: height);
  // }

  // Widget _buildFloatingCodeCard(BuildContext context) {
  //   return CodeCardWidget(
  //     card: _currentCard,
  //     maxWidth: 720,
  //     onTap: _showFullscreenCode,
  //     showLogo: true,
  //   );
  // }

  // // Format a numeric code into groups of 4 digits for readability, e.g.
  // // 2292220484809 -> "2292 2204 8480 9". Non-digit characters are preserved
  // // and grouping applies to sequences of digits.
  // String _formatCode(String raw) {
  //   final buffer = StringBuffer();
  //   final digitRuns = RegExp(r"\d+").allMatches(raw);
  //   int lastIndex = 0;
  //   for (final match in digitRuns) {
  //     // Append any non-digit chars preceding this run
  //     if (match.start > lastIndex) {
  //       buffer.write(raw.substring(lastIndex, match.start));
  //     }
  //     final digits = match.group(0) ?? '';
  //     // Group into chunks of 4 from the start
  //     final groups = <String>[];
  //     for (var i = 0; i < digits.length; i += 4) {
  //       groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
  //     }
  //     buffer.write(groups.join(' '));
  //     lastIndex = match.end;
  //   }
  //   if (lastIndex < raw.length) {
  //     buffer.write(raw.substring(lastIndex));
  //   }
  //   return buffer.toString();
  // }

  // // _formatCode removed — barcode value displayed raw to match tests and
  // // avoid accidental transformations during share/export.
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
