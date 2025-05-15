import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/card_item.dart';

enum CardType { BARCODE, QR_CODE }

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage>
    with SingleTickerProviderStateMixin {
  String? _scannedData;
  bool _isManualEntry = false;
  CardType _selectedCardType = CardType.QR_CODE;
  String _detectedFormatString =
      ''; // Changed to avoid conflict with l10n getter

  // Controllers for manual input fields
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Add controller for animations
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _barcodeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validation functions
  String? _validateBarcode(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validationPleaseEnterValue;
    }

    if (_selectedCardType == CardType.BARCODE) {
      if (!RegExp(r'^[0-9a-zA-Z]+$').hasMatch(value)) {
        return l10n.validationBarcodeOnlyAlphanumeric;
      }
      if (value.length < 3) {
        return l10n.validationBarcodeMinLength;
      }
    }
    return null;
  }

  String? _validateTitle(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validationTitleRequired;
    }
    if (value.length < 3) {
      return l10n.validationTitleMinLength;
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value != null && value.isNotEmpty && value.length < 5) {
      return l10n.validationDescriptionMinLength;
    }
    return null;
  }

  // Show success feedback to user
  void _showScanSuccessUI(BuildContext context, String format) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.scanSuccessMessage(format)), // Use localized string
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Animate and scroll to form
    setState(() {
      _isScanning = false;
    });
    _animationController.forward();

    // Scroll to form after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          300, // Approximate position to scroll to form
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get l10n instance
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCard)), // Use localized string
      body: Column(
        children: [
          // Toggle buttons for scan/manual entry
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment<bool>(
                  value: false,
                  label: Text(l10n.scanBarcode), // Use localized string
                  icon: const Icon(Icons.qr_code_scanner),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text(l10n.manualEntry), // Use localized string
                  icon: const Icon(Icons.keyboard),
                ),
              ],
              selected: {_isManualEntry},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _isManualEntry = selection.first;
                });
              },
            ),
          ),

          // Display either scanner or manual input form
          Expanded(
            child:
                _isManualEntry
                    ? _buildManualEntryForm(l10n)
                    : _buildScanner(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner(AppLocalizations l10n) {
    // Pass l10n
    return Column(
      children: [
        // Display detected barcode type if available
        if (_scannedData != null && _detectedFormatString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  l10n.detectedFormat(
                    _detectedFormatString,
                  ), // Use localized string
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Scanner area with visual indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isScanning ? 300 : 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Scanner widget
                      MobileScanner(
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty && _isScanning) {
                            final barcode = barcodes.first;
                            // Check if rawValue is not null
                            if (barcode.rawValue != null) {
                              setState(() {
                                _scannedData = barcode.rawValue;
                                _barcodeController.text = _scannedData ?? '';

                                // Safely check the format to avoid null errors
                                final formatName = barcode.format.toString();
                                if (formatName.toLowerCase().contains("qr")) {
                                  _detectedFormatString =
                                      l10n.textQrCode; // Use localized string
                                  _selectedCardType = CardType.QR_CODE;
                                } else {
                                  _detectedFormatString =
                                      l10n.textBarcode; // Use localized string
                                  _selectedCardType = CardType.BARCODE;
                                }

                                // Show success UI
                                _showScanSuccessUI(
                                  context,
                                  _detectedFormatString,
                                );
                              });
                            }
                          }
                        },
                      ),

                      // Scanner overlay animation
                      if (_isScanning)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: 250,
                          height: 250,
                        ),
                    ],
                  ),
                ),

                // Form section below scanner
                if (_scannedData != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Let user override the detected type
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Type: '),
                              SegmentedButton<CardType>(
                                segments: [
                                  ButtonSegment<CardType>(
                                    value: CardType.BARCODE,
                                    label: Text(
                                      l10n.barcode,
                                    ), // Use localized string
                                    icon: const Icon(Icons.barcode_reader),
                                  ),
                                  ButtonSegment<CardType>(
                                    value: CardType.QR_CODE,
                                    label: Text(
                                      l10n.qrCode,
                                    ), // Use localized string
                                    icon: const Icon(Icons.qr_code),
                                  ),
                                ],
                                selected: {_selectedCardType},
                                onSelectionChanged: (Set<CardType> selection) {
                                  setState(() {
                                    _selectedCardType = selection.first;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Add validation for title
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: l10n.title, // Use localized string
                              hintText: l10n.titleHint, // Use localized string
                              border: const OutlineInputBorder(),
                            ),
                            validator: _validateTitle,
                          ),
                          const SizedBox(height: 10),
                          // Add validation for description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText:
                                  l10n.description, // Use localized string
                              hintText:
                                  l10n.descriptionHint, // Use localized string
                              border: const OutlineInputBorder(),
                            ),
                            validator: _validateDescription,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (_scannedData != null &&
                                  _formKey.currentState!.validate()) {
                                Navigator.pop(
                                  context,
                                  CardItem.temp(
                                    // Use the temporary constructor
                                    title:
                                        _titleController.text.isNotEmpty
                                            ? _titleController.text
                                            : l10n.appTitle,
                                    description:
                                        _descriptionController.text.isNotEmpty
                                            ? _descriptionController.text
                                            : '',
                                    name: _scannedData!,
                                    cardType: _selectedCardType.name,
                                  ),
                                );
                              } else if (_scannedData == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.noDataScanned,
                                    ), // Use localized string
                                  ),
                                );
                              }
                            },
                            child: Text(l10n.addCard), // Use localized string
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryForm(AppLocalizations l10n) {
    // Pass l10n
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Wrap in SingleChildScrollView for keyboard scrolling
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card type selection for manual entry
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<CardType>(
                      segments: [
                        ButtonSegment<CardType>(
                          value: CardType.BARCODE,
                          label: Text(l10n.barcode), // Use localized string
                          icon: const Icon(Icons.barcode_reader),
                        ),
                        ButtonSegment<CardType>(
                          value: CardType.QR_CODE,
                          label: Text(l10n.qrCode), // Use localized string
                          icon: const Icon(Icons.qr_code),
                        ),
                      ],
                      selected: {_selectedCardType},
                      onSelectionChanged: (Set<CardType> selection) {
                        setState(() {
                          _selectedCardType = selection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText:
                      _selectedCardType == CardType.BARCODE
                          ? l10n.barcodeValue
                          : l10n.qrCodeValue, // Use localized string
                  hintText:
                      _selectedCardType == CardType.BARCODE
                          ? l10n.enterBarcodeValue
                          : l10n.enterQrCodeValue, // Use localized string
                  border: const OutlineInputBorder(),
                ),
                validator: _validateBarcode,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title, // Use localized string
                  hintText: l10n.titleHint, // Use localized string
                  border: const OutlineInputBorder(),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.description, // Use localized string
                  hintText: l10n.descriptionHint, // Use localized string
                  border: const OutlineInputBorder(),
                ),
                validator: _validateDescription,
              ),
              // Remove the Spacer here
              const SizedBox(height: 32.0), // Add padding instead
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      CardItem.temp(
                        // Use the temporary constructor
                        title:
                            _titleController.text.isNotEmpty
                                ? _titleController.text
                                : l10n.appTitle,
                        description:
                            _descriptionController.text.isNotEmpty
                                ? _descriptionController.text
                                : '',
                        name: _barcodeController.text,
                        cardType: _selectedCardType.name,
                      ),
                    );
                  }
                },
                child: Text(l10n.addCard), // Use localized string
              ),
              const SizedBox(
                height: 20.0,
              ), // Add bottom padding for better visibility
            ],
          ),
        ),
      ),
    );
  }
}
