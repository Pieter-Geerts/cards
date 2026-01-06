import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/edit_card_page.dart';
import '../services/brightness_service.dart';
import '../services/share_service.dart';
import '../widgets/logo_avatar_widget.dart';

class CardDetailPage extends StatefulWidget {
  final CardItem card;
  final Function(CardItem)? onDelete;

  const CardDetailPage({super.key, required this.card, this.onDelete});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage>
    with SingleTickerProviderStateMixin {
  // Layout constants
  static const double _floatingCardTopOffset = 8.0;
  static const double _codeCard2DWidthMultiplier = 0.85;
  static const double _codeCard1DWidthMultiplier = 0.95;
  static const double _codeCard1DHeight = 140.0;
  static const double _codeCardMinWidth = 120.0;
  static const double _codeCardMaxWidth = 1200.0;
  static const double _headerHeight = 200.0;
  static const double _headerLogoSize = 88.0;
  static const double _floatingCardTopPadding = 220.0;
  static const double _floatingCardHorizontalPadding = 20.0;
  static const double _descriptionMaxHeight = 80.0;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late CardItem _currentCard;
  bool _descExpanded = false;
  double? _originalBrightness;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _titleController = TextEditingController(text: _currentCard.title);
    _descController = TextEditingController(text: _currentCard.description);
    // Defer brightness change until after first frame so UI is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setBrightnessToMax();
    });
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
      // Store original brightness and set to maximum using service.
      _originalBrightness = await BrightnessService.current();
      if (_originalBrightness == null) _originalBrightness = 0.5;
      await BrightnessService.set(1.0);

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
        await BrightnessService.set(_originalBrightness!);
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
        try {
          await DatabaseHelper().deleteCard(_currentCard.id!);
        } catch (e, st) {
          debugPrint('Failed deleting card from DB: $e\n$st');
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
          return;
        }

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
    // Delegate the sharing flow to the centralized ShareService. This honors
    // `ShareService.testShareHook` in tests (which allows fast short-circuiting)
    // and keeps sharing logic consistent across the app.
    setState(() => _isSharing = true);
    try {
      await ShareService.shareCardAsImageStatic(context, _currentCard);
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _handleShare() async {
    if (ShareService.testShareHook != null) {
      await ShareService.testShareHook!(context, _currentCard);
    } else {
      await _shareCardAsImage();
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
                      onPressed: () => _handleShare(),
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
    final topOffset =
        MediaQuery.of(context).padding.top +
        kToolbarHeight +
        _floatingCardTopOffset;
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
                  icon:
                      _isSharing
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.onBackground,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.share,
                            color: theme.colorScheme.onBackground,
                          ),
                  tooltip: l10n.shareAsImage,
                  onPressed: _isSharing ? null : () => _handleShare(),
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
                        height: _headerHeight,
                        child: Center(
                          child: LogoAvatarWidget(
                            logoKey: _currentCard.logoPath,
                            title: _currentCard.title,
                            size: _headerLogoSize,
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
                    padding: EdgeInsets.fromLTRB(
                      _floatingCardHorizontalPadding,
                      _floatingCardTopPadding,
                      _floatingCardHorizontalPadding,
                      24,
                    ),
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
                                          : BoxConstraints(
                                            maxHeight: _descriptionMaxHeight,
                                          ),
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
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ), // end Scaffold
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
    final size =
        _currentCard.is2D ? availableWidth * _codeCard2DWidthMultiplier : null;
    final width =
        _currentCard.is1D ? availableWidth * _codeCard1DWidthMultiplier : null;
    // Increase 1D barcode height so scanners can read it more reliably.
    final height = _currentCard.is1D ? _codeCard1DHeight : null;

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
                    _codeCardMinWidth,
                    _codeCardMaxWidth,
                  );
                  return _buildCodeWidget(available);
                },
              ),
            ),
            if (_currentCard.isBarcode) ...[
              const SizedBox(height: 12),
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
            ],
          ],
        ),
      ),
    );
  }

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
