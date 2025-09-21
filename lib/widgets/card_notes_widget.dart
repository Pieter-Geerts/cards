// Displays card notes/description.
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';

class CardNotesWidget extends StatelessWidget {
  final CardItem card;
  const CardNotesWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(l10n.notes, style: theme.textTheme.titleMedium),
      tilePadding: EdgeInsets.zero,
      collapsedIconColor: theme.colorScheme.primary,
      iconColor: theme.colorScheme.primary,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            card.description.isNotEmpty ? card.description : l10n.noNotes,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
