import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../helpers/logo_helper.dart';
import '../l10n/app_localizations.dart';
import '../services/logo_cache_service.dart';
import '../utils/simple_icons_mapping.dart';

class LogoSelectionSheet extends StatefulWidget {
  final IconData? currentLogo;
  final String cardTitle;
  final void Function(IconData?)? onLogoSelected;

  const LogoSelectionSheet({
    super.key,
    this.currentLogo,
    this.cardTitle = '',
    this.onLogoSelected,
  });

  @override
  State<LogoSelectionSheet> createState() => _LogoSelectionSheetState();
}

class _LogoSelectionSheetState extends State<LogoSelectionSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  IconData? _selectedLogo;
  IconData? _suggestedLogo;
  List<IconData> _availableLogos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedLogo = widget.currentLogo;
    _loadLogoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLogoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _suggestedLogo = await LogoHelper.suggestLogo(widget.cardTitle);
      _availableLogos = await LogoCacheService.instance.getAllAvailableLogos();
    } catch (e) {
      debugPrint('Error loading logo data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadLogo() async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        extensions: <String>['jpg', 'jpeg', 'png', 'svg'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );

      if (file != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).customLogoUploadComingSoon,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).errorUploadingLogo}: ${e.toString()}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _selectLogo(IconData? logo) {
    setState(() {
      _selectedLogo = logo;
    });
  }

  void _confirmSelection() {
    if (widget.onLogoSelected != null) {
      widget.onLogoSelected!(_selectedLogo);
      Navigator.of(context).pop();
      return;
    }

    final identifier =
        _selectedLogo == null
            ? null
            : SimpleIconsMapping.getIdentifier(_selectedLogo!);
    Navigator.of(context).pop<String?>(identifier);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(200),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).selectLogo,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Current selection preview
            if (_selectedLogo != null || widget.currentLogo != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedLogo ?? widget.currentLogo,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).selectedLogo,
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            _selectedLogo == null
                                ? AppLocalizations.of(context).removeLogo
                                : AppLocalizations.of(context).selectedLogo,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (_selectedLogo != null)
                      IconButton(
                        onPressed: () => _selectLogo(null),
                        icon: const Icon(Icons.clear),
                        tooltip: AppLocalizations.of(context).removeLogo,
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: AppLocalizations.of(context).suggested,
                  icon: const Icon(Icons.auto_awesome),
                ),
                Tab(
                  text: AppLocalizations.of(context).browse,
                  icon: const Icon(Icons.grid_view),
                ),
                Tab(
                  text: AppLocalizations.of(context).uploadLogo,
                  icon: const Icon(Icons.upload),
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSuggestedTab(),
                  _buildBrowseTab(),
                  _buildUploadTab(),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outline, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      child: Text(AppLocalizations.of(context).confirm),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestedLogo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No logo suggestion found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try browsing available logos or upload your own',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Based on "${widget.cardTitle}"',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (widget.onLogoSelected != null) {
                _selectLogo(_suggestedLogo);
              } else {
                final id = SimpleIconsMapping.getIdentifier(_suggestedLogo!);
                Navigator.of(context).pop<String?>(id);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _selectedLogo == _suggestedLogo
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                  width: _selectedLogo == _suggestedLogo ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _suggestedLogo,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).suggestedLogo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableLogos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noLogosAvailable,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _availableLogos.length,
      itemBuilder: (context, index) {
        final logo = _availableLogos[index];
        final isSelected = _selectedLogo == logo;

        return GestureDetector(
          onTap: () {
            if (widget.onLogoSelected != null) {
              _selectLogo(logo);
            } else {
              final id = SimpleIconsMapping.getIdentifier(logo);
              Navigator.of(context).pop<String?>(id);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                logo,
                size: 32,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Upload Custom Logo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a PNG, JPG, or SVG file from your device',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploadLogo,
            icon: const Icon(Icons.folder_open),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Custom logo upload coming soon!',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
