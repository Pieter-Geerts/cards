import 'dart:async'; // Added for Timer (debouncer)

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../utils/simple_icons_mapping.dart';
import '../widgets/logo_avatar_widget.dart';
import '../widgets/simple_logo_selection_sheet.dart';

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
  String? _logoPath; // Actual saved logo path
  String? _pendingLogoPath; // Temporary logo path for editing
  IconData? _pendingLogoIcon; // Temporary Simple Icon for editing

  late CardType _selectedCardType; // To hold current card type enum
  bool _hasUnsavedChanges = false;
  Timer? _debouncer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descController = TextEditingController(text: widget.card.description);
    _nameController = TextEditingController(
      text: widget.card.name,
    ); // Code value
    _logoPath = widget.card.logoPath;
    _pendingLogoPath = _logoPath; // Start with current logo path

    // Check if the logo path is a Simple Icon identifier
    if (_logoPath != null && _logoPath!.startsWith('simple_icon:')) {
      // Convert to IconData for editing
      _pendingLogoIcon = _getIconDataFromIdentifier(_logoPath!);
      _pendingLogoPath = null; // Clear path since we're using icon
    } else {
      _pendingLogoIcon = null; // No icon selected initially
    }

    _selectedCardType = widget.card.cardType;

    // Listen for changes to mark as unsaved
    _titleController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
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
      bool logoChanged =
          _pendingLogoPath != widget.card.logoPath || _pendingLogoIcon != null;
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
      _pendingLogoIcon = null;
    });
    _onFieldChanged();
  }

  void _save() {
    // Determine the final logo path to save
    String? finalLogoPath = _pendingLogoPath;

    // If we have a Simple Icon selected, convert it to a string identifier
    if (_pendingLogoIcon != null) {
      // Find the icon name from the helper's logo map
      finalLogoPath = _getSimpleIconIdentifier(_pendingLogoIcon!);
    }

    final updatedCard = widget.card.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      name: _nameController.text.trim(),
      logoPath: finalLogoPath,
      cardType: _selectedCardType,
    );
    // Support sync or async onSave handlers; show saving indicator.
    // onSave is a synchronous callback in this codebase; show a brief saving state
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }
    try {
      widget.onSave(updatedCard);
    } catch (e) {
      debugPrint('Error while saving card: $e');
    }
    if (mounted) {
      setState(() {
        _logoPath = finalLogoPath; // Update the saved logo path
        _pendingLogoPath = finalLogoPath;
        _pendingLogoIcon = null; // Clear the pending icon since it's now saved
        _hasUnsavedChanges = false;
        _isSaving = false;
      });
      Navigator.of(context).pop();
    }
  }

  /// Converts an IconData to a Simple Icon string identifier
  String? _getSimpleIconIdentifier(IconData iconData) {
    return SimpleIconsMapping.getIdentifier(iconData);
  }

  /// Converts a Simple Icon string identifier to IconData
  IconData? _getIconDataFromIdentifier(String identifier) {
    return SimpleIconsMapping.getIcon(identifier);
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

  void _openLogoSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => LogoSelectionSheet(
            currentLogo: _pendingLogoIcon,
            cardTitle: _titleController.text,
            onLogoSelected: (selectedLogo) {
              setState(() {
                _pendingLogoIcon = selectedLogo;
                // Clear the path if we're using an icon
                if (selectedLogo != null) {
                  _pendingLogoPath = null;
                }
                _onFieldChanged();
              });
            },
          ),
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
            _isSaving
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: SizedBox(
                    width: 48,
                    height: kToolbarHeight,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                : IconButton(
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
                // Logo section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Show current logo if exists
                      if (_pendingLogoPath != null &&
                              _pendingLogoPath!.isNotEmpty ||
                          _pendingLogoIcon != null)
                        Column(
                          children: [
                            Text(
                              l10n.currentLogo,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            LogoAvatarWidget(
                              logoKey: _pendingLogoPath,
                              logoIcon: _pendingLogoIcon,
                              title: _titleController.text,
                              size: 100,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: Text(l10n.removeLogoButton),
                                  onPressed: _removeLogo,
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: Text('Edit Logo'),
                                  onPressed: _openLogoSelectionSheet,
                                ),
                              ],
                            ),
                          ],
                        )
                      // Show add logo button if no logo exists
                      else
                        Column(
                          children: [
                            Text(
                              'Logo',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: Text('Add Logo'),
                              onPressed: _openLogoSelectionSheet,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
