import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddCard;
  final VoidCallback? onScan;

  const EmptyStateWidget({super.key, required this.onAddCard, this.onScan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCardsYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Save loyalty and membership cards here. Scan or add them manually.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddCard,
                icon: const Icon(Icons.add),
                label: Text(l10n.addCard),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            if (onScan != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.scanBarcodeCTA),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
