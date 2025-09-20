import 'package:flutter/material.dart';

import '../../config/preset_cards.dart';
import '../../l10n/app_localizations.dart';

class AddCardStepPreset extends StatelessWidget {
  final PresetCard? selectedPreset;
  final bool isGenericSelected;
  final ValueChanged<PresetCard?> onPresetSelected;
  final ValueChanged<bool> onGenericSelected;

  const AddCardStepPreset({
    super.key,
    required this.selectedPreset,
    required this.isGenericSelected,
    required this.onPresetSelected,
    required this.onGenericSelected,
  });

  @override
  Widget build(BuildContext context) {
    final gridCards = List<PresetCard>.from(kPresetCards);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Generic card representation is built inline in the grid's last item

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).quickAdd,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: gridCards.length + 1, // +1 for generic card
                  itemBuilder: (context, index) {
                    if (index < gridCards.length) {
                      final preset = gridCards[index];
                      return GestureDetector(
                        onTap: () => onPresetSelected(preset),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                selectedPreset == preset
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  selectedPreset == preset
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withAlpha(10),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                preset.logoIcon,
                                size: 32,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                preset.title,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Generic card option
                      return GestureDetector(
                        onTap: () => onGenericSelected(true),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isGenericSelected
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isGenericSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withAlpha(10),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 32,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  200,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).genericCard,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
