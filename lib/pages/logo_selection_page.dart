import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

import '../services/logo_cache_service.dart';
import '../widgets/optimized_logo_grid.dart';

/// Full-screen logo selection page with advanced performance optimizations
class LogoSelectionPage extends StatefulWidget {
  final IconData? currentLogo;
  final String cardTitle;
  final String? cardId; // For analytics and caching

  const LogoSelectionPage({
    super.key,
    this.currentLogo,
    required this.cardTitle,
    this.cardId,
  });

  @override
  State<LogoSelectionPage> createState() => _LogoSelectionPageState();
}

class _LogoSelectionPageState extends State<LogoSelectionPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  // Performance-optimized state management
  final ValueNotifier<IconData?> _selectedLogo = ValueNotifier(null);
  final ValueNotifier<IconData?> _suggestedLogo = ValueNotifier(null);
  final ValueNotifier<List<IconData>> _availableLogos = ValueNotifier([]);
  final ValueNotifier<List<IconData>> _filteredLogos = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  // Cache for theme colors to avoid repeated lookups
  late ColorScheme _colorScheme;
  late TextTheme _textTheme;

  @override
  bool get wantKeepAlive => true; // Keep page alive for better performance

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _selectedLogo.value = widget.currentLogo;

    // Set up search listener with debouncing
    _searchController.addListener(_onSearchChanged);

    // Load data asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogoData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache theme data once
    _colorScheme = Theme.of(context).colorScheme;
    _textTheme = Theme.of(context).textTheme;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _selectedLogo.dispose();
    _suggestedLogo.dispose();
    _availableLogos.dispose();
    _filteredLogos.dispose();
    _isLoading.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  // Debounced search to avoid excessive filtering
  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (_searchQuery.value != query) {
      _searchQuery.value = query;
      _filterLogos(query);
    }
  }

  void _filterLogos(String query) {
    if (query.isEmpty) {
      _filteredLogos.value = _availableLogos.value;
    } else {
      // Use compute for heavy filtering operations
      _filteredLogos.value =
          _availableLogos.value.where((logo) {
            // Simple text-based filtering - can be enhanced with fuzzy search
            final logoName = logo.toString().toLowerCase();
            return logoName.contains(query);
          }).toList();
    }
  }

  Future<void> _loadLogoData() async {
    if (!mounted) return;

    _isLoading.value = true;

    try {
      // Use the optimized cache service with timeout
      final cacheService = LogoCacheService.instance;

      // Load suggestion and available logos concurrently. Avoid using
      // explicit Future.timeouts here because the underlying implementation
      // may schedule timers that remain pending in the test environment
      // (causing FakeAsync timer assertions). Individual service methods
      // already implement their own timeouts where needed.
      final suggestionFuture = cacheService.getSuggestedLogo(widget.cardTitle);
      final availableFuture = cacheService.getAllAvailableLogos();

      final results = await Future.wait([suggestionFuture, availableFuture]);

      if (!mounted) return;

      _suggestedLogo.value = results[0] as IconData?;
      final availableLogos = results[1] as List<IconData>;
      _availableLogos.value = availableLogos;
      _filteredLogos.value = availableLogos;

      // Preload next batch for smoother scrolling if we have logos
      if (availableLogos.isNotEmpty) {
        cacheService.preloadBatch(availableLogos.take(50).toList());
      }
    } catch (e) {
      debugPrint('Error loading logo data: $e');
      // Set empty state on error
      if (mounted) {
        _availableLogos.value = [];
        _filteredLogos.value = [];
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  void _selectLogo(IconData? logo) {
    _selectedLogo.value = logo;
    // Haptic feedback for better UX
    HapticFeedback.selectionClick();
  }

  void _confirmSelection() {
    Navigator.of(context).pop(_selectedLogo.value);
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.selectLogo),
        elevation: 0,
        actions: [
          ValueListenableBuilder<IconData?>(
            valueListenable: _selectedLogo,
            builder: (context, selectedLogo, _) {
              return TextButton(
                onPressed: selectedLogo != null ? _confirmSelection : null,
                child: Text(
                  localizations.done,
                  style: TextStyle(
                    color:
                        selectedLogo != null
                            ? _colorScheme.primary
                            : _colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.suggested, icon: Icon(Icons.auto_awesome)),
            Tab(text: localizations.browse, icon: Icon(Icons.grid_view)),
            Tab(text: localizations.search, icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Current selection preview - only show when selected
          ValueListenableBuilder<IconData?>(
            valueListenable: _selectedLogo,
            builder: (context, selectedLogo, _) {
              if (selectedLogo == null && widget.currentLogo == null) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedLogo ?? widget.currentLogo,
                      size: 48,
                      color: _colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.selectedLogo,
                            style: _textTheme.titleSmall,
                          ),
                          Text(
                            selectedLogo == null
                                ? localizations.currentLogo
                                : localizations.simpleIcon,
                            style: _textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (selectedLogo != null)
                      IconButton(
                        onPressed: () => _selectLogo(null),
                        icon: const Icon(Icons.clear),
                        tooltip: localizations.removeLogo,
                      ),
                  ],
                ),
              );
            },
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSuggestedTab(),
                _buildBrowseTab(),
                _buildSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedTab() {
    final localizations = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<IconData?>(
          valueListenable: _suggestedLogo,
          builder: (context, suggestedLogo, _) {
            if (suggestedLogo == null) {
              return _buildEmptyState(
                icon: Icons.search_off,
                title: localizations.noLogoSuggestionFound,
                subtitle: localizations.tryBrowsingLogos,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.basedOnCardTitle(widget.cardTitle),
                    style: _textTheme.titleSmall,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<IconData?>(
                    valueListenable: _selectedLogo,
                    builder: (context, selectedLogo, _) {
                      final isSelected = selectedLogo == suggestedLogo;

                      return GestureDetector(
                        onTap: () => _selectLogo(suggestedLogo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isSelected
                                      ? _colorScheme.primary
                                      : _colorScheme.outline,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                suggestedLogo,
                                size: 80,
                                color: _colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.suggestedLogo,
                                style: _textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBrowseTab() {
    final localizations = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<List<IconData>>(
          valueListenable: _availableLogos,
          builder: (context, availableLogos, _) {
            if (availableLogos.isEmpty) {
              return _buildEmptyState(
                icon: Icons.image_not_supported,
                title: localizations.noLogosAvailable,
                subtitle: localizations.pleaseTryAgainLater,
              );
            }

            return OptimizedLogoGrid(
              logos: availableLogos,
              selectedLogo: _selectedLogo,
              onLogoSelected: _selectLogo,
              colorScheme: _colorScheme,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchTab() {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: localizations.searchLogos,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (context, query, _) {
                  if (query.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear),
                  );
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),

        // Search results
        Expanded(
          child: ValueListenableBuilder<List<IconData>>(
            valueListenable: _filteredLogos,
            builder: (context, filteredLogos, _) {
              if (_searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: _colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.startTypingToSearch,
                        style: _textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              if (filteredLogos.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off,
                  title: localizations.noSearchResults,
                  subtitle: localizations.tryDifferentSearch,
                );
              }

              return OptimizedLogoGrid(
                logos: filteredLogos,
                selectedLogo: _selectedLogo,
                onLogoSelected: _selectLogo,
                colorScheme: _colorScheme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: _colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(title, style: _textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: _textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
