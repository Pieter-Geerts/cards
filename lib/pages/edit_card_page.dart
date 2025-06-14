import 'dart:async'; // Added for Timer (debouncer)

import 'package:barcode_widget/barcode_widget.dart'; // Added for BarcodeWidget
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Added for QrImageView

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/home_page.dart' show buildLogoWidget;

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
  late TextEditingController _nameController; // This is for the code value
  String? _logoPath;

  late CardType _selectedCardType; // To hold current card type enum
  bool _hasUnsavedChanges = false;
  Timer? _debouncer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descController = TextEditingController(text: widget.card.description);
    _nameController = TextEditingController(
      text: widget.card.name,
    ); // Code value
    _logoPath = widget.card.logoPath;
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
      _logoPath = null;
      _onFieldChanged();
    });
  }

  void _save() {
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
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.title,
                    hintText: l10n.titleHint,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    hintText: l10n.descriptionHint,
                  ),
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CardType>(
                  decoration: InputDecoration(labelText: l10n.cardTypeLabel),
                  value: _selectedCardType,
                  items:
                      CardType.values.map((cardType) {
                        return DropdownMenuItem(
                          value: cardType,
                          child: Text(cardType.displayName),
                        );
                      }).toList(),
                  onChanged: (CardType? newValue) {
                    if (newValue != null && newValue != _selectedCardType) {
                      setState(() {
                        _selectedCardType = newValue;
                        _onFieldChanged(); // Update unsaved changes status
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.codeValueLabel,
                    hintText:
                        _selectedCardType == CardType.qrCode
                            ? l10n.enterQrCodeValue
                            : l10n.enterBarcodeValue,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged:
                      (_) => setState(() {
                        _onFieldChanged();
                      }), // Trigger rebuild for preview & check changes
                ),
                const SizedBox(height: 24),
                if (codeValueForPreview.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(
                          8,
                        ), // Padding around the code
                        decoration: BoxDecoration(
                          // White background for the code
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child:
                            _selectedCardType == CardType.qrCode
                                ? QrImageView(
                                  data: codeValueForPreview,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  eyeStyle: const QrEyeStyle(
                                    color: Colors.black,
                                  ), // Added
                                  dataModuleStyle: const QrDataModuleStyle(
                                    color: Colors.black,
                                  ), // Added
                                  // backgroundColor: Colors.white, // Handled by container
                                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                                )
                                : BarcodeWidget(
                                  barcode: Barcode.code128(),
                                  data: codeValueForPreview,
                                  width: 280,
                                  height: 100,
                                  drawText: false,
                                  // backgroundColor: Colors.white, // Handled by container
                                  color: Colors.black,
                                ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Logo display (if exists)
                if (_logoPath != null && _logoPath!.isNotEmpty)
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
                        buildLogoWidget(
                          _logoPath,
                          width: 100,
                          height: 100,
                          title: _titleController.text,
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
