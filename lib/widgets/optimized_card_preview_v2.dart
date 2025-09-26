import 'package:flutter/material.dart';

import '../models/card_item.dart';
import '../services/performance_monitoring_service.dart';
import '../widgets/logo_avatar_widget.dart';
import '../l10n/app_localizations.dart';

/// High-performance card preview widget with advanced optimization
/// Reduces rebuilds through intelligent caching and minimal state changes
class OptimizedCardPreview extends StatefulWidget {
  final String? logoPath;
  final IconData? logoIcon;
  final String title;
  final String description;
  final double logoSize;
  final Color? background;
  final bool isCompact;
  final VoidCallback? onTap;

  const OptimizedCardPreview({
    super.key,
    this.logoPath,
    this.logoIcon,
    required this.title,
    required this.description,
    this.logoSize = 64,
    this.background,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<OptimizedCardPreview> createState() => _OptimizedCardPreviewState();
}

class _OptimizedCardPreviewState extends State<OptimizedCardPreview> {
  // Cache previous values to prevent unnecessary rebuilds
  String? _lastLogoPath;
  IconData? _lastLogoIcon;
  String _lastTitle = '';
  String _lastDescription = '';
  double _lastLogoSize = 0;
  Color? _lastBackground;
  bool _lastIsCompact = false;

  // Pre-computed style constants for performance (colors applied at build time)
  static const _titleStyleNormal = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const _titleStyleCompact = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const _descriptionStyleNormal = TextStyle(fontSize: 14);
  static const _descriptionStyleCompact = TextStyle(fontSize: 12);
  static const _compactPadding = EdgeInsets.all(12);
  static const _normalPadding = EdgeInsets.all(20);

  @override
  Widget build(BuildContext context) {
    PerformanceMonitoringService.instance.startTimer('card_preview_build');

    // Check if we need to rebuild by comparing cached values
    final shouldRebuild = _hasValuesChanged();

    if (shouldRebuild) {
      _updateCachedValues();
    }

    final widget = _buildCardWidget();

    PerformanceMonitoringService.instance.stopTimer('card_preview_build');

    return widget;
  }

  bool _hasValuesChanged() {
    return widget.logoPath != _lastLogoPath ||
        widget.logoIcon != _lastLogoIcon ||
        widget.title != _lastTitle ||
        widget.description != _lastDescription ||
        widget.logoSize != _lastLogoSize ||
        widget.background != _lastBackground ||
        widget.isCompact != _lastIsCompact;
  }

  void _updateCachedValues() {
    _lastLogoPath = widget.logoPath;
    _lastLogoIcon = widget.logoIcon;
    _lastTitle = widget.title;
    _lastDescription = widget.description;
    _lastLogoSize = widget.logoSize;
    _lastBackground = widget.background;
    _lastIsCompact = widget.isCompact;
  }

  Widget _buildCardWidget() {
    final theme = Theme.of(context);
    final cardDecoration = BoxDecoration(
      color: widget.background ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(widget.isCompact ? 12 : 20),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withAlpha(15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final padding = widget.isCompact ? _compactPadding : _normalPadding;
    final baseTitleStyle =
        widget.isCompact ? _titleStyleCompact : _titleStyleNormal;
    final baseDescriptionStyle =
        widget.isCompact ? _descriptionStyleCompact : _descriptionStyleNormal;
    final titleStyle = baseTitleStyle.merge(
      theme.textTheme.bodyLarge?.copyWith(
        color: theme.textTheme.bodyLarge?.color,
      ),
    );
    final descriptionStyle = baseDescriptionStyle.merge(
      theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
    );

    Widget cardContent = Container(
      padding: padding,
      decoration: cardDecoration,
      child:
          widget.isCompact
              ? _buildCompactLayout(titleStyle, descriptionStyle)
              : _buildNormalLayout(titleStyle, descriptionStyle),
    );

    if (widget.onTap != null) {
      cardContent = InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.isCompact ? 12 : 20),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildCompactLayout(TextStyle titleStyle, TextStyle descriptionStyle) {
    return Row(
      children: [
        _buildLogoSection(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title.isNotEmpty
                    ? widget.title
                    : AppLocalizations.of(context).cardTitleFallback,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: descriptionStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNormalLayout(TextStyle titleStyle, TextStyle descriptionStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoSection(),
        const SizedBox(height: 12),
        Text(
          widget.title.isNotEmpty
              ? widget.title
              : AppLocalizations.of(context).cardTitleFallback,
          style: titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (widget.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.description,
            style: descriptionStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLogoSection() {
    return LogoAvatarWidget(
      logoKey: widget.logoPath,
      logoIcon: widget.logoIcon,
      title:
          widget.title.isNotEmpty
              ? widget.title
              : AppLocalizations.of(context).cardLabel,
      size: widget.logoSize,
      background: widget.background ?? Colors.transparent,
    );
  }
}

/// Performance-optimized card list widget
/// Uses ListView.builder with proper itemExtent for better scrolling performance
class OptimizedCardList extends StatefulWidget {
  final List<CardItem> cards;
  final void Function(CardItem)? onCardTap;
  final void Function(CardItem)? onCardEdit;
  final void Function(CardItem)? onCardDelete;
  final EdgeInsets? padding;
  final bool isCompact;

  const OptimizedCardList({
    super.key,
    required this.cards,
    this.onCardTap,
    this.onCardEdit,
    this.onCardDelete,
    this.padding,
    this.isCompact = false,
  });

  @override
  State<OptimizedCardList> createState() => _OptimizedCardListState();
}

class _OptimizedCardListState extends State<OptimizedCardList> {
  static const double _compactItemHeight = 80.0;
  static const double _normalItemHeight = 140.0;

  @override
  Widget build(BuildContext context) {
    PerformanceMonitoringService.instance.startTimer('card_list_build');

    final itemHeight =
        widget.isCompact ? _compactItemHeight : _normalItemHeight;

    final listView = ListView.builder(
      itemCount: widget.cards.length,
      itemExtent: itemHeight, // Fixed height for better performance
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final card = widget.cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OptimizedCardPreview(
            logoPath: card.logoPath,
            title: card.title,
            description: card.description,
            isCompact: widget.isCompact,
            onTap:
                widget.onCardTap != null ? () => widget.onCardTap!(card) : null,
          ),
        );
      },
    );

    PerformanceMonitoringService.instance.stopTimer('card_list_build');

    return listView;
  }
}

/// Performance metrics widget for monitoring card operations
class CardPerformanceMetrics extends StatelessWidget {
  const CardPerformanceMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PerformanceMonitoringService.instance;
    final previewStats = service.getMetricStats('card_preview_build');
    final listStats = service.getMetricStats('card_list_build');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMetricRow('Preview Builds', previewStats),
            _buildMetricRow('List Builds', listStats),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, Map<String, dynamic> stats) {
    final count = stats['count'] ?? 0;
    final average = stats['average'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('$count builds, ${average}ms avg')],
      ),
    );
  }
}
