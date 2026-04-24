import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/card_item.dart';
import 'add_card_options.dart';

class AddCardStepCodeAcquisition extends StatelessWidget {
  final TextEditingController codeController;
  final CardType cardType;
  final ValueChanged<CardType> onCardTypeChanged;
  final ValueNotifier<bool> showManualEntry;
  final VoidCallback onScan;
  final VoidCallback onImageImport;
  final VoidCallback onManualEntry;

  const AddCardStepCodeAcquisition({
    Key? key,
    required this.codeController,
    required this.cardType,
    required this.onCardTypeChanged,
    required this.showManualEntry,
    required this.onScan,
    required this.onImageImport,
    required this.onManualEntry,
  }) : super(key: key);

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
            child: AddCardPrimaryOption(
              icon: Icons.qr_code_scanner_outlined,
              title: AppLocalizations.of(context).scanBarcodeCTA,
              subtitle: AppLocalizations.of(context).useCameraToScan,
              color: Theme.of(context).colorScheme.primary,
              onTap: onScan,
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
                      color: Theme.of(context).hintColor,
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
                AddCardSecondaryOption(
                  key: const ValueKey('import_from_image_option'),
                  icon: Icons.photo_library_outlined,
                  title: AppLocalizations.of(context).importFromImage,
                  subtitle: AppLocalizations.of(context).choosePhotoWithBarcode,
                  onTap: onImageImport,
                ),
                const SizedBox(height: 16),
                AddCardSecondaryOption(
                  icon: Icons.edit_outlined,
                  title: AppLocalizations.of(context).manualEntryFull,
                  subtitle: AppLocalizations.of(context).typeCodeManually,
                  onTap: onManualEntry,
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: showManualEntry,
                  builder: (context, visible, _) {
                    if (!visible) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(51),
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
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: Theme.of(context).colorScheme.primary,
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

                          // Card type dropdown
                          DropdownButton<CardType>(
                            value: cardType,
                            items:
                                CardType.values.map((type) {
                                  return DropdownMenuItem<CardType>(
                                    value: type,
                                    child: Text(
                                      type.getLocalizedDisplayName(context),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (CardType? value) {
                              if (value != null) onCardTypeChanged(value);
                            },
                          ),
                          const SizedBox(height: 20),

                          // Enhanced code input
                          Text(
                            AppLocalizations.of(context).code,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x08000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: codeController,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    cardType == CardType.qrCode
                                        ? AppLocalizations.of(
                                          context,
                                        ).enterQrCodeValue
                                        : AppLocalizations.of(
                                          context,
                                        ).enterBarcodeValue,
                                hintStyle: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).hintColor,
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.fillColor ??
                                    Theme.of(context).colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade600
                                            : Colors.grey.shade200,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF4CAF50),
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.qr_code_outlined,
                                  color: Theme.of(context).hintColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.paste_outlined,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  tooltip:
                                      AppLocalizations.of(
                                        context,
                                      ).pasteFromClipboard,
                                  onPressed: () async {
                                    try {
                                      final clipboardData =
                                          await Clipboard.getData(
                                            Clipboard.kTextPlain,
                                          );
                                      final text = clipboardData?.text ?? '';
                                      if (text.isNotEmpty) {
                                        codeController.text = text.trim();
                                      }
                                    } catch (_) {}
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          AnimatedBuilder(
                            animation: codeController,
                            builder: (context, _) {
                              final codeText = codeController.text.trim();
                              if (codeText.isEmpty)
                                return const SizedBox.shrink();
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceTint.withAlpha(18),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        codeText,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.copy_outlined,
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      tooltip:
                                          AppLocalizations.of(
                                            context,
                                          ).codeCopiedToClipboard,
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        await Clipboard.setData(
                                          ClipboardData(text: codeText),
                                        );
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              ).codeCopiedToClipboard,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
