import 'dart:async'; // Added for Timer (debouncer)

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../widgets/logo_avatar_widget.dart';

class EditCardPage extends StatefulWidget {
  final CardItem card;
  final void Function(CardItem) onSave;

  const EditCardPage({super.key, required this.card, required this.onSave});

  @override
  State<EditCardPage> createState() => _EditCardPageState();
}

class _EditCardPageState extends State<EditCardPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _nameController;
  String? _logoPath; // Actual saved logo
  String? _pendingLogoPath; // Temporary logo selection for editing

  late CardType _selectedCardType; // To hold current card type enum
  bool _hasUnsavedChanges = false;
  Timer? _debouncer;

  String? _suggestedLogoAsset;
  bool _logoSuggestionChecked = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descController = TextEditingController(text: widget.card.description);
    _nameController = TextEditingController(
      text: widget.card.name,
    ); // Code value
    _logoPath = widget.card.logoPath;
    _pendingLogoPath = _logoPath; // Start with current logo
    _selectedCardType = widget.card.cardType;

    // Listen for changes to mark as unsaved
    _titleController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _descController.removeListener(_onFieldChanged);
    _nameController.removeListener(_onFieldChanged);

    _titleController.dispose();
    _descController.dispose();
    _nameController.dispose();
    _debouncer?.cancel();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) {
      // Check if actual values have changed from the original card
      bool titleChanged = _titleController.text != widget.card.title;
      bool descChanged = _descController.text != widget.card.description;
      bool nameChanged = _nameController.text != widget.card.name;
      bool logoChanged = _logoPath != widget.card.logoPath;
      bool typeChanged = _selectedCardType != widget.card.cardType;

      final newHasUnsavedChanges =
          titleChanged ||
          descChanged ||
          nameChanged ||
          logoChanged ||
          typeChanged;

      if (newHasUnsavedChanges != _hasUnsavedChanges) {
        setState(() {
          _hasUnsavedChanges = newHasUnsavedChanges;
        });
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _pendingLogoPath = null;
      _onFieldChanged();
    });
  }

  void _save() {
    setState(() {
      _logoPath = _pendingLogoPath; // Only apply changes on save
    });
    final updatedCard = widget.card.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      name: _nameController.text.trim(),
      logoPath: _logoPath,
      cardType: _selectedCardType,
    );
    widget.onSave(updatedCard);
    if (mounted) {
      setState(() {
        _hasUnsavedChanges = false;
      });
      Navigator.of(context).pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final l10n = AppLocalizations.of(context);
      final shouldPop = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(l10n.unsavedChangesTitle),
              content: Text(l10n.unsavedChangesMessage),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.stayButton),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(l10n.discardButton),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  void _onTitleChanged() async {
    final normalized = _titleController.text.trim().toLowerCase().replaceAll(
      ' ',
      '',
    );
    if (normalized.isEmpty) {
      setState(() {
        _suggestedLogoAsset = null;
        _logoSuggestionChecked = false;
      });
      return;
    }
    final assetPath = 'assets/icons/$normalized.svg';
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      setState(() {
        _suggestedLogoAsset = assetPath;
        _logoSuggestionChecked = true;
      });
    } catch (_) {
      setState(() {
        _suggestedLogoAsset = null;
        _logoSuggestionChecked = true;
      });
    }
  }

  Widget _buildLogoSuggestion() {
    if (!_logoSuggestionChecked) return SizedBox.shrink();
    if (_suggestedLogoAsset == null) {
      return Text(
        'No logo suggestion found.',
        style: TextStyle(color: Colors.grey),
      );
    }
    final isSelected = _pendingLogoPath == _suggestedLogoAsset;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested logo:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SvgPicture.asset(_suggestedLogoAsset!, height: 48),
        SizedBox(height: 8),
        isSelected
            ? TextButton.icon(
              icon: const Icon(Icons.close),
              label: Text('Remove Logo'),
              onPressed: _removeLogo,
            )
            : ElevatedButton(
              onPressed: () {
                setState(() {
                  _pendingLogoPath = _suggestedLogoAsset;
                  _onFieldChanged();
                });
              },
              child: Text('Use this logo'),
            ),
      ],
    );
  }

  Widget _buildCodeVisualization(
    String codeValue,
    CardType cardType, {
    String? title,
    String? description,
    String? logoPath,
  }) {
    return CardItem(
      title: title ?? '',
      description: description ?? '',
      name: codeValue,
      cardType: cardType,
      logoPath: logoPath,
      sortOrder: 0,
    ).renderCode(
      size: cardType.is2D ? 160 : null,
      width: cardType.is1D ? 200 : null,
      height: cardType.is1D ? 80 : null,
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController controller,
    String hint, {
    bool optional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
            if (optional)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '(Optioneel)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    CardType value,
    ValueChanged<CardType?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<CardType>(
          value: value,
          items:
              CardType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final codeValueForPreview = _nameController.text.trim();

    return PopScope<void>(
      // Changed from WillPopScope
      canPop:
          false, // When true, allows popping. When false, callback is called.
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        // Store the navigator and context values before the await
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();

        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editCard),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed:
                  (_titleController.text.trim().isNotEmpty &&
                          _nameController.text.trim().isNotEmpty &&
                          _hasUnsavedChanges)
                      ? _save
                      : null,
              tooltip: l10n.save,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabeledField(
                  l10n.title,
                  _titleController,
                  l10n.titleHint,
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  l10n.description,
                  _descController,
                  l10n.descriptionHint,
                  optional: true,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(l10n.cardTypeLabel, _selectedCardType, (
                  CardType? newValue,
                ) {
                  if (newValue != null && newValue != _selectedCardType) {
                    setState(() {
                      _selectedCardType = newValue;
                      _onFieldChanged(); // Update unsaved changes status
                    });
                  }
                }),
                const SizedBox(height: 16),
                _buildLabeledField(
                  l10n.codeValueLabel,
                  _nameController,
                  _selectedCardType == CardType.qrCode
                      ? l10n.enterQrCodeValue
                      : l10n.enterBarcodeValue,
                ),
                const SizedBox(height: 24),
                if (codeValueForPreview.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: _buildCodeVisualization(
                          codeValueForPreview,
                          _selectedCardType,
                          title: _titleController.text,
                          description: _descController.text,
                          logoPath: _pendingLogoPath,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Logo display (if exists)
                if (_pendingLogoPath != null && _pendingLogoPath!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.currentLogo,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        LogoAvatarWidget(
                          logoKey: _pendingLogoPath,
                          title: _titleController.text,
                          size: 100,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.removeLogoButton),
                          onPressed: _removeLogo,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        ),
                        // Add Edit Logo button
                        TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: Text('Edit Logo'),
                          onPressed: () {
                            setState(() {
                              // Show logo suggestion UI
                              _logoSuggestionChecked = false;
                              _onTitleChanged();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                _buildLogoSuggestion(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
