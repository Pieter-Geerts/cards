import 'package:flutter/material.dart';

import 'add_card_form_page.dart';

class AddCardEntryPage extends StatelessWidget {
  const AddCardEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaart Toevoegen'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Main scan button
            _buildPrimaryOption(
              context,
              icon: Icons.qr_code_scanner,
              title: 'Scan Barcode',
              subtitle: 'Gebruik je camera om een code te scannen',
              color: Theme.of(context).primaryColor,
              onTap: () => _navigateToForm(context, AddCardMode.scan),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'of',
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

            // Secondary options
            _buildSecondaryOption(
              context,
              icon: Icons.image,
              title: 'Scan vanuit Afbeelding',
              subtitle: 'Selecteer een afbeelding uit je galerij',
              onTap: () => _navigateToForm(context, AddCardMode.gallery),
            ),

            const SizedBox(height: 12),

            _buildSecondaryOption(
              context,
              icon: Icons.edit,
              title: 'Handmatige Invoer',
              subtitle: 'Typ de code handmatig in',
              onTap: () => _navigateToForm(context, AddCardMode.manual),
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

  void _navigateToForm(BuildContext context, AddCardMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddCardFormPage(mode: mode)),
    );
  }
}

enum AddCardMode { scan, gallery, manual }
