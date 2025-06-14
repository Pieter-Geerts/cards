import 'dart:async'; // Added for Timer (debouncer)

import 'package:barcode_widget/barcode_widget.dart'; // Added for BarcodeWidget
import 'package:cards/config.dart'; // Use config instead of secrets
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Added for QrImageView

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';
import '../pages/home_page.dart' show buildLogoWidget;
import '../services/logo_dev_service.dart';

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
  late LogoDevService _logoService;
  final TextEditingController _logoSearchController = TextEditingController();
  bool _isSearchingLogo = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _logoPath;

  late String
  _selectedCardType; // To hold current card type: 'BARCODE' or 'QR_CODE'
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
    _logoService = LogoDevService(logoDevApiKey);
    _logoPath = widget.card.logoPath;
    _selectedCardType = widget.card.cardType;

    // Listen for changes to mark as unsaved
    _titleController.addListener(_onFieldChanged);
    _descController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
    _logoSearchController.addListener(
      _onFieldChanged,
    ); // Also if user types in logo search

    // Listener for automatic logo search from title
    _titleController.addListener(_onTitleChangedForAutoLogoSearch);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _titleController.removeListener(_onTitleChangedForAutoLogoSearch);
    _descController.removeListener(_onFieldChanged);
    _nameController.removeListener(_onFieldChanged);
    _logoSearchController.removeListener(_onFieldChanged);

    _titleController.dispose();
    _descController.dispose();
    _nameController.dispose();
    _logoSearchController.dispose();
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

  void _onTitleChangedForAutoLogoSearch() {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 750), () {
      final title = _titleController.text.trim();
      if (title.isNotEmpty && title.length > 2 && _logoPath == null) {
        // Only auto-search if no logo is set yet
        _searchLogo(title, triggeredByTitleChange: true);
      }
    });
  }

  Future<void> _searchLogo(
    String query, {
    bool triggeredByTitleChange = false,
  }) async {
    if (query.isEmpty) return;
    setState(() {
      _isSearchingLogo = true;
      if (!triggeredByTitleChange) {
        _searchResults = [];
      }
    });
    try {
      final results = await _logoService.searchCompanies(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchingLogo = false;
        });
        if (results.isEmpty && !triggeredByTitleChange) {
          // Show error if search was manual and no results
          _showErrorDialog(
            AppLocalizations.of(context).logoSearchFailedTitle,
            AppLocalizations.of(context).logoSearchFailedMessage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingLogo = false;
        });
        _showErrorDialog(
          AppLocalizations.of(context).logoSearchFailedTitle,
          AppLocalizations.of(context).logoSearchFailedMessage,
        );
      }
    }
  }

  Future<void> _downloadAndSetLogo(String companyNameOrDomain) async {
    setState(
      () => _isSearchingLogo = true,
    ); // Keep loading indicator during download
    try {
      final filePath = await _logoService.downloadAndSaveLogo(
        companyNameOrDomain,
      );
      if (mounted) {
        if (filePath != null) {
          setState(() {
            _logoPath = filePath;
            _searchResults = [];
            _logoSearchController.clear();
            _hasUnsavedChanges = true; // Mark changes
          });
        } else {
          // Show download failed error
          _showErrorDialog(
            AppLocalizations.of(context).logoDownloadFailedTitle,
            AppLocalizations.of(context).logoDownloadFailedMessage,
          );
        }
        setState(() => _isSearchingLogo = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearchingLogo = false);
        _showErrorDialog(
          AppLocalizations.of(context).logoDownloadFailedTitle,
          AppLocalizations.of(context).logoDownloadFailedMessage,
        );
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _removeLogo() {
    setState(() {
      _logoPath = null;
      _onFieldChanged(); // Update unsaved changes status
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
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.cardTypeLabel),
                  value: _selectedCardType,
                  items: [
                    DropdownMenuItem(
                      value: 'QR_CODE',
                      child: Text(l10n.qrCode),
                    ),
                    DropdownMenuItem(
                      value: 'BARCODE',
                      child: Text(l10n.barcode),
                    ),
                  ],
                  onChanged: (String? newValue) {
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
                        _selectedCardType == 'QR_CODE'
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
                            _selectedCardType == 'QR_CODE'
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
                TextField(
                  controller: _logoSearchController,
                  decoration: InputDecoration(
                    labelText: l10n.searchLogoAction,
                    hintText: l10n.searchLogoHint,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed:
                          _logoSearchController.text.trim().isEmpty
                              ? null
                              : () => _searchLogo(
                                _logoSearchController.text.trim(),
                              ),
                    ),
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      _searchLogo(query.trim());
                    }
                  },
                ),
                if (_isSearchingLogo)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_searchResults.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: buildLogoWidget(
                            result['logo_url'],
                            width: 40,
                            height: 40,
                          ),
                          title: Text(result['name'] ?? ''),
                          subtitle: Text(result['domain'] ?? ''),
                          onTap:
                              () => _downloadAndSetLogo(
                                result['domain'] ?? result['name'] ?? '',
                              ),
                        );
                      },
                    ),
                  ),
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
                        buildLogoWidget(_logoPath, width: 100, height: 100),
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

// Add these new l10n keys to your .arb files:
// "save": "Save" (if not already present for the tooltip)
// "currentLogo": "Current Logo"
// "searchLogoHint": "Enter company name for logo"
// "unsavedChangesTitle": "Unsaved Changes" (already added)
// "unsavedChangesMessage": "You have unsaved changes. Do you want to discard them?" (already added)
// "discardButton": "Discard" (already added)
// "stayButton": "Stay" (already added)
// "cardTypeLabel": "Card Type" (already added)
// "removeLogoButton": "Remove Logo" (already added)
// "ok": "OK" (add this to all arb files)
