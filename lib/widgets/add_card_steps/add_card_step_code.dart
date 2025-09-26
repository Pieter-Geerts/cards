import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/card_item.dart';

class AddCardStepCode extends StatelessWidget {
  final CardType cardType;
  final TextEditingController codeController;
  final ValueChanged<CardType> onCardTypeChanged;
  final VoidCallback onScan;
  final VoidCallback onImageImport;
  final VoidCallback onManualEntry;
  final bool showManualEntry;
  const AddCardStepCode({
    super.key,
    required this.cardType,
    required this.codeController,
    required this.onCardTypeChanged,
    required this.onScan,
    required this.onImageImport,
    required this.onManualEntry,
    required this.showManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppLocalizations.of(context).howAddCode,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              label: Text(AppLocalizations.of(context).scanBarcodeCTA),
              onPressed: onScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context).or,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(AppLocalizations.of(context).importFromImage),
                  onPressed: onImageImport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(AppLocalizations.of(context).manualEntryFull),
                  onPressed: onManualEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showManualEntry) ...[
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(51),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).manualEntryFull,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).cardTypeLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CardType>(
                    value: cardType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor ??
                          Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    items:
                        CardType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                    onChanged: (CardType? value) {
                      if (value != null) onCardTypeChanged(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context).code,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          cardType == CardType.qrCode
                              ? AppLocalizations.of(context).qrCodeValue
                              : AppLocalizations.of(context).barcodeValue,
                      filled: true,
                      fillColor:
                          Theme.of(context).inputDecorationTheme.fillColor ??
                          Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.qr_code_outlined,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withAlpha(153),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
