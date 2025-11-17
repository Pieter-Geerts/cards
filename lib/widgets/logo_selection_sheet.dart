import 'package:flutter/material.dart';

import '../services/logo_cache_service.dart';
import '../utils/simple_icons_mapping.dart';

/// Bottom sheet to pick a SimpleIcon identifier for a card logo.
class LogoSelectionSheet extends StatefulWidget {
  const LogoSelectionSheet({super.key});

  @override
  State<LogoSelectionSheet> createState() => _LogoSelectionSheetState();
}

class _LogoSelectionSheetState extends State<LogoSelectionSheet> {
  bool _isLoading = true;
  List<IconData> _icons = [];

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    try {
      final logos = await LogoCacheService.instance.getAllAvailableLogos();
      if (mounted) {
        setState(() {
          _icons = logos;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load logos: $e');
      if (mounted) {
        setState(() {
          _icons = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Kies een logo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _icons.length,
                        itemBuilder: (context, index) {
                          final icon = _icons[index];
                          final identifier = SimpleIconsMapping.getIdentifier(
                            icon,
                          );
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop(identifier);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: Center(
                                  child: Icon(
                                    icon,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
