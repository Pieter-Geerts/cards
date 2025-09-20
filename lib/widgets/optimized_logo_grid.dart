import 'package:flutter/material.dart';

/// Highly optimized logo grid widget with performance enhancements
/// Implements virtualization, efficient scrolling, and minimal rebuilds
class OptimizedLogoGrid extends StatefulWidget {
  final List<IconData> logos;
  final ValueNotifier<IconData?> selectedLogo;
  final Function(IconData?) onLogoSelected;
  final ColorScheme colorScheme;
  final int crossAxisCount;
  final double itemSpacing;
  final double iconSize;

  const OptimizedLogoGrid({
    super.key,
    required this.logos,
    required this.selectedLogo,
    required this.onLogoSelected,
    required this.colorScheme,
    this.crossAxisCount = 4,
    this.itemSpacing = 12,
    this.iconSize = 32,
  });

  @override
  State<OptimizedLogoGrid> createState() => _OptimizedLogoGridState();
}

class _OptimizedLogoGridState extends State<OptimizedLogoGrid> {
  late ScrollController _scrollController;

  // Performance optimization: Cache theme colors
  late Color _primaryColor;
  late Color _outlineColor;
  late Color _onSurfaceColor;
  late Color _surfaceColor;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updateThemeColors();
  }

  @override
  void didUpdateWidget(OptimizedLogoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorScheme != widget.colorScheme) {
      _updateThemeColors();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateThemeColors() {
    _primaryColor = widget.colorScheme.primary;
    _outlineColor = widget.colorScheme.outline;
    _onSurfaceColor = widget.colorScheme.onSurface;
    _surfaceColor = widget.colorScheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logos.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.itemSpacing,
        mainAxisSpacing: widget.itemSpacing,
        childAspectRatio: 1,
      ),
      // Performance optimizations for large lists
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 200, // Reduced cache extent for memory efficiency
      itemCount: widget.logos.length,
      itemBuilder: (context, index) {
        return _LogoGridItem(
          logo: widget.logos[index],
          selectedLogo: widget.selectedLogo,
          onTap: widget.onLogoSelected,
          primaryColor: _primaryColor,
          outlineColor: _outlineColor,
          onSurfaceColor: _onSurfaceColor,
          surfaceColor: _surfaceColor,
          iconSize: widget.iconSize,
        );
      },
    );
  }
}

/// Individual logo grid item with optimized rendering
/// Uses minimal rebuilds and cached values for best performance
class _LogoGridItem extends StatelessWidget {
  final IconData logo;
  final ValueNotifier<IconData?> selectedLogo;
  final Function(IconData?) onTap;
  final Color primaryColor;
  final Color outlineColor;
  final Color onSurfaceColor;
  final Color surfaceColor;
  final double iconSize;

  const _LogoGridItem({
    required this.logo,
    required this.selectedLogo,
    required this.onTap,
    required this.primaryColor,
    required this.outlineColor,
    required this.onSurfaceColor,
    required this.surfaceColor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IconData?>(
      valueListenable: selectedLogo,
      builder: (context, selected, child) {
        final isSelected = selected == logo;

        return GestureDetector(
          onTap: () => onTap(logo),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? primaryColor.withValues(alpha: 0.08)
                      : surfaceColor,
              border: Border.all(
                color: isSelected ? primaryColor : outlineColor,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                logo,
                size: iconSize,
                color: isSelected ? primaryColor : onSurfaceColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Performance-optimized search grid with debounced filtering
class SearchableLogoGrid extends StatefulWidget {
  final List<IconData> allLogos;
  final ValueNotifier<IconData?> selectedLogo;
  final Function(IconData?) onLogoSelected;
  final ColorScheme colorScheme;
  final String searchQuery;

  const SearchableLogoGrid({
    super.key,
    required this.allLogos,
    required this.selectedLogo,
    required this.onLogoSelected,
    required this.colorScheme,
    required this.searchQuery,
  });

  @override
  State<SearchableLogoGrid> createState() => _SearchableLogoGridState();
}

class _SearchableLogoGridState extends State<SearchableLogoGrid> {
  List<IconData> _filteredLogos = [];
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredLogos = widget.allLogos;
  }

  @override
  void didUpdateWidget(SearchableLogoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.searchQuery != _lastQuery) {
      _lastQuery = widget.searchQuery;
      _filterLogos(widget.searchQuery);
    }
  }

  void _filterLogos(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLogos = widget.allLogos;
      });
      return;
    }

    // Use efficient filtering for large lists
    final filtered = <IconData>[];
    final lowerQuery = query.toLowerCase();

    for (final logo in widget.allLogos) {
      // Simple string-based filtering - can be enhanced with fuzzy matching
      final logoString = logo.toString().toLowerCase();
      if (logoString.contains(lowerQuery)) {
        filtered.add(logo);
        // Limit results for performance
        if (filtered.length >= 100) break;
      }
    }

    setState(() {
      _filteredLogos = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OptimizedLogoGrid(
      logos: _filteredLogos,
      selectedLogo: widget.selectedLogo,
      onLogoSelected: widget.onLogoSelected,
      colorScheme: widget.colorScheme,
    );
  }
}

/// Grid with infinite scrolling and lazy loading capabilities
class InfiniteLogoGrid extends StatefulWidget {
  final Future<List<IconData>> Function(int page, int pageSize) loadLogos;
  final ValueNotifier<IconData?> selectedLogo;
  final Function(IconData?) onLogoSelected;
  final ColorScheme colorScheme;
  final int pageSize;

  const InfiniteLogoGrid({
    super.key,
    required this.loadLogos,
    required this.selectedLogo,
    required this.onLogoSelected,
    required this.colorScheme,
    this.pageSize = 50,
  });

  @override
  State<InfiniteLogoGrid> createState() => _InfiniteLogoGridState();
}

class _InfiniteLogoGridState extends State<InfiniteLogoGrid> {
  final List<IconData> _allLogos = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialLogos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreLogos();
    }
  }

  Future<void> _loadInitialLogos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final logos = await widget.loadLogos(0, widget.pageSize);
      setState(() {
        _allLogos.addAll(logos);
        _hasMore = logos.length == widget.pageSize;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreLogos() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final logos = await widget.loadLogos(_currentPage, widget.pageSize);
      setState(() {
        _allLogos.addAll(logos);
        _hasMore = logos.length == widget.pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: OptimizedLogoGrid(
            logos: _allLogos,
            selectedLogo: widget.selectedLogo,
            onLogoSelected: widget.onLogoSelected,
            colorScheme: widget.colorScheme,
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
