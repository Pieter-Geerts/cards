import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

import '../helpers/logo_helper.dart';
import '../models/card_item.dart';
import '../services/app_navigator.dart';
import '../widgets/card_preview_widget.dart';
import 'add_card_entry_page.dart';

class AddCardFormPage extends StatefulWidget {
  final AddCardMode mode;
  final String? scannedCode; // Pre-filled from scanner

  const AddCardFormPage({super.key, required this.mode, this.scannedCode});

  @override
  State<AddCardFormPage> createState() => _AddCardFormPageState();
}

class _AddCardFormPageState extends State<AddCardFormPage> {
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // State
  CardType _cardType = CardType.qrCode;
  String? _logoPath;
  IconData? _selectedLogoIcon;
  bool _isLoadingLogo = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    // Pre-fill code if scanned
    if (widget.scannedCode != null) {
      _codeController.text = widget.scannedCode!;
      // Auto-detect card type based on scanned code format
      _cardType = _detectCardType(widget.scannedCode!);
    }

    // Set up logo auto-suggestion when title changes
    _titleController.addListener(_onTitleChanged);
  }

  CardType _detectCardType(String code) {
    // Simple heuristics to detect code type
    if (code.length > 20 || code.contains('http') || code.contains('.')) {
      return CardType.qrCode;
    }
    return CardType.barcode;
  }

  Future<void> _onTitleChanged() async {
    final title = _titleController.text.trim();
    if (title.length < 3) return; // Wait for meaningful input

    setState(() => _isLoadingLogo = true);

    try {
      final suggestion = await LogoHelper.suggestLogo(title);
      if (suggestion != null && mounted) {
        setState(() {
          _selectedLogoIcon = suggestion;
          _logoPath = null; // Clear custom logo when auto-suggestion found
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLogo = false);
      }
    }
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case AddCardMode.scan:
        return 'Gescande Kaart';
      case AddCardMode.gallery:
        return 'Afbeelding Kaart';
      case AddCardMode.manual:
        return 'Nieuwe Kaart';
    }
  }

  String _getModeSubtitle() {
    switch (widget.mode) {
      case AddCardMode.scan:
        return 'Controleer en bewerk de gescande gegevens';
      case AddCardMode.gallery:
        return 'Controleer en bewerk de afbeelding gegevens';
      case AddCardMode.manual:
        return 'Vul alle gegevens handmatig in';
    }
  }

  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _codeController.text.trim().isNotEmpty;
  }

  Future<void> _saveCard() async {
    if (!_isFormValid()) return;

    final logoPath =
        _selectedLogoIcon != null && _logoPath == null
            ? _getSimpleIconIdentifier(_selectedLogoIcon!)
            : _logoPath;

    final newCard = CardItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      name: _codeController.text.trim(),
      cardType: _cardType,
      logoPath: logoPath,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );

    if (mounted) {
      Navigator.of(context).pop(newCard);
    }
  }

  String? _getSimpleIconIdentifier(IconData icon) {
    final iconMap = {
      SimpleIcons.carrefour: 'simple_icon:carrefour',
      SimpleIcons.aldinord: 'simple_icon:aldinord',
      SimpleIcons.lidl: 'simple_icon:lidl',
      SimpleIcons.walmart: 'simple_icon:walmart',
      SimpleIcons.target: 'simple_icon:target',
      SimpleIcons.tesco: 'simple_icon:tesco',
      SimpleIcons.ikea: 'simple_icon:ikea',
      SimpleIcons.nike: 'simple_icon:nike',
      SimpleIcons.adidas: 'simple_icon:adidas',
      SimpleIcons.puma: 'simple_icon:puma',
      SimpleIcons.zara: 'simple_icon:zara',
      SimpleIcons.amazon: 'simple_icon:amazon',
      SimpleIcons.ebay: 'simple_icon:ebay',
      SimpleIcons.etsy: 'simple_icon:etsy',
      SimpleIcons.shopify: 'simple_icon:shopify',
      SimpleIcons.mcdonalds: 'simple_icon:mcdonalds',
      SimpleIcons.burgerking: 'simple_icon:burgerking',
      SimpleIcons.kfc: 'simple_icon:kfc',
      SimpleIcons.starbucks: 'simple_icon:starbucks',
      SimpleIcons.tacobell: 'simple_icon:tacobell',
    };
    return iconMap[icon];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getModeTitle()),
        elevation: 0,
        actions: [
          if (widget.mode == AddCardMode.scan)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                // TODO: Re-scan functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opnieuw scannen komt binnenkort!'),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(16),
            child: Text(
              _getModeSubtitle(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Preview Section
                  _buildCardPreview(),
                  const SizedBox(height: 24),

                  // Smart Logo Section
                  _buildLogoSection(),
                  const SizedBox(height: 24),

                  // Form Fields
                  _buildFormFields(),
                ],
              ),
            ),
          ),

          // Save Button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Voorbeeld',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_isLoadingLogo)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Center(
              child: CardPreviewWidget(
                logoPath:
                    _selectedLogoIcon != null && _logoPath == null
                        ? _getSimpleIconIdentifier(_selectedLogoIcon!)
                        : _logoPath,
                title: _titleController.text,
                description: _descriptionController.text,
                logoSize: 64,
                background: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Auto-suggested logo
            if (_selectedLogoIcon != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedLogoIcon,
                      size: 32,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automatisch gevonden',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Logo voor "${_titleController.text}"',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedLogoIcon = null),
                      icon: Icon(Icons.close, color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Logo action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.store),
                    label: const Text('Zoek Logo'),
                    onPressed: _openLogoSelectionSheet,
                  ),
                ),
              ],
            ),

            if (_selectedLogoIcon != null || _logoPath != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Verwijder Logo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed:
                      () => setState(() {
                        _selectedLogoIcon = null;
                        _logoPath = null;
                      }),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Title field
        _buildLabeledField(
          'Titel *',
          _titleController,
          'Naam van de winkel of service',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Description field
        _buildLabeledField(
          'Omschrijving',
          _descriptionController,
          'Extra details (bijv. lidmaatschapsnummer)',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Card type dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type Kaart',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CardType>(
                  value: _cardType,
                  isExpanded: true,
                  onChanged: (CardType? newValue) {
                    setState(() => _cardType = newValue!);
                  },
                  items:
                      CardType.values.map<DropdownMenuItem<CardType>>((
                        CardType value,
                      ) {
                        return DropdownMenuItem<CardType>(
                          value: value,
                          child: Text(value.displayName),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Code field
        _buildLabeledField(
          'Code/Barcode *',
          _codeController,
          _cardType == CardType.qrCode
              ? 'QR code inhoud of URL'
              : 'Barcode nummer',
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String hintText, {
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isFormValid() ? _saveCard : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kaart Opslaan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          if (!_isFormValid()) ...[
            const SizedBox(height: 8),
            Text(
              'Vul minimaal titel en code in om op te slaan',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _openLogoSelectionSheet() async {
    final selectedLogo = await AppNavigator.instance.pushLogoSelection(
      cardTitle: _titleController.text,
      currentLogo: _selectedLogoIcon,
    );

    if (selectedLogo != null) {
      setState(() {
        _selectedLogoIcon = selectedLogo;
        _logoPath = null;
      });
    }
  }
}
