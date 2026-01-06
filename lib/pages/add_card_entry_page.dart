import 'package:flutter/material.dart';

import '../helpers/image_scan_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import 'add_card_form_page.dart';
import 'camera_scan_page.dart';
import 'image_scan_page.dart';

class AddCardEntryPage extends StatefulWidget {
  const AddCardEntryPage({super.key});

  @override
  State<AddCardEntryPage> createState() => _AddCardEntryPageState();
}

class _AddCardEntryPageState extends State<AddCardEntryPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCard), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Main scan button - Camera
            _buildPrimaryOption(
              context,
              icon: Icons.qr_code_scanner,
              title: l10n.scanBarcodeCTA,
              subtitle: l10n.useCameraToScan,
              color: Theme.of(context).primaryColor,
              onTap: () => _navigateToCameraScan(context),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.or,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(200),
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 16),

            // Secondary options - Image
            _buildSecondaryOption(
              context,
              icon: Icons.image,
              title: l10n.importFromImage,
              subtitle: l10n.scanFromImageSubtitle,
              onTap: () => _navigateToImageScan(context),
            ),

            const SizedBox(height: 12),

            // Manual entry
            _buildSecondaryOption(
              context,
              icon: Icons.edit,
              title: l10n.manualEntryFull,
              subtitle: l10n.typeCodeManually,
              onTap: () => _navigateToManualForm(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(200),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCameraScan(BuildContext context) {
    Navigator.of(context)
        .push<(String code, CardType type)>(
          MaterialPageRoute(
            builder:
                (context) => CameraScanPage(
                  onCodeScanned: (code, type) {
                    Navigator.of(context).pop((code, type));
                  },
                ),
          ),
        )
        .then((result) {
          if (result != null) {
            _navigateToFormWithCode(context, result.$1, result.$2);
          }
        });
  }

  void _navigateToImageScan(BuildContext context) async {
    final result = await ImageScanHelper.pickAndScanImage();
    if (!mounted) return;

    if (result != null) {
      final imagePath = result['imagePath'] as String;
      // Open image scan page to detect code
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      final scanResult = await Navigator.of(
        context,
      ).push<(String code, CardType type)?>(
        MaterialPageRoute(
          builder:
              (context) => ImageScanPage(
                imagePath: imagePath,
                onCodeEntered: (code, type) {
                  Navigator.of(context).pop((code, type));
                },
              ),
        ),
      );

      if (scanResult != null && mounted) {
        _navigateToFormWithCode(context, scanResult.$1, scanResult.$2);
      }
    }
  }

  void _navigateToManualForm(BuildContext context) {
    // ignore: use_build_context_synchronously
    Navigator.of(context).push<CardItem?>(
      MaterialPageRoute(
        builder:
            (context) => const AddCardFormPage(
              mode: AddCardMode.manual,
              scannedCode: null,
            ),
      ),
    );
  }

  void _navigateToFormWithCode(
    BuildContext context,
    String code,
    CardType type,
  ) {
    // ignore: use_build_context_synchronously
    Navigator.of(context).push<CardItem?>(
      MaterialPageRoute(
        builder:
            (context) => AddCardFormPage(
              mode: AddCardMode.scan,
              scannedCode: code,
              scannedType: type,
            ),
      ),
    );
  }
}

enum AddCardMode { scan, gallery, manual }
