import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/logo_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../services/app_navigator.dart';
import '../utils/simple_icons_mapping.dart';
import '../widgets/card_preview_widget.dart';
import '../widgets/labeled_field.dart';
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
  Timer? _logoDebounce;

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

    // Set up logo auto-suggestion when title changes (debounced)
    _titleController.addListener(_onTitleChanged);
  }

  CardType _detectCardType(String code) {
    // Simple heuristics to detect code type
    if (code.length > 20 || code.contains('http') || code.contains('.')) {
      return CardType.qrCode;
    }
    return CardType.barcode;
  }

  void _onTitleChanged() {
    final title = _titleController.text.trim();
    // Debounce suggestions to avoid many calls while typing
    _logoDebounce?.cancel();
    if (title.length < 3) return;
    _logoDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
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
        if (mounted) setState(() => _isLoadingLogo = false);
      }
    });
  }

  String _getModeTitle() {
    switch (widget.mode) {
      case AddCardMode.scan:
        return AppLocalizations.of(context).modeScanTitle;
      case AddCardMode.gallery:
        return AppLocalizations.of(context).modeGalleryTitle;
      case AddCardMode.manual:
        return AppLocalizations.of(context).modeManualTitle;
    }
  }

  String _getModeSubtitle() {
    switch (widget.mode) {
      case AddCardMode.scan:
        return AppLocalizations.of(context).modeScanSubtitle;
      case AddCardMode.gallery:
        return AppLocalizations.of(context).modeGallerySubtitle;
      case AddCardMode.manual:
        return AppLocalizations.of(context).modeManualSubtitle;
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

  String? _getSimpleIconIdentifier(IconData icon) =>
      SimpleIconsMapping.getIdentifier(icon);

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
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).rescanComingSoon,
                    ),
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
                Text(
                  AppLocalizations.of(context).preview,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
            Text(
              AppLocalizations.of(context).logoLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                            AppLocalizations.of(context).logoAutoFound,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).logoForTitle(_titleController.text),
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
                    label: Text(AppLocalizations.of(context).searchLogo),
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
                  label: Text(
                    AppLocalizations.of(context).removeLogo,
                    style: const TextStyle(color: Colors.red),
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
        LabeledField(
          label: AppLocalizations.of(context).title + ' *',
          controller: _titleController,
          hint: AppLocalizations.of(context).storeName,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Description field
        LabeledField(
          label: AppLocalizations.of(context).description,
          controller: _descriptionController,
          hint: AppLocalizations.of(context).optionalDescription,
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Card type dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).cardTypeLabel,
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
                  // ignore: deprecated_member_use
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
        LabeledField(
          label:
              AppLocalizations.of(context).code +
              ' / ' +
              AppLocalizations.of(context).barcode +
              ' *',
          controller: _codeController,
          hint:
              _cardType == CardType.qrCode
                  ? AppLocalizations.of(context).enterQrCodeValue
                  : AppLocalizations.of(context).enterBarcodeValue,
          onChanged: (_) => setState(() {}),
          keyboardType:
              _cardType == CardType.barcode
                  ? TextInputType.number
                  : TextInputType.url,
          inputFormatters:
              _cardType == CardType.barcode
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
              child: Text(
                AppLocalizations.of(context).save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          if (!_isFormValid()) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).validationPleaseEnterValue,
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
