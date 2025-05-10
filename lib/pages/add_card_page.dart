import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _detectedFormat = '';

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
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }

    // For barcodes, we might want to check if it's numeric
    if (_selectedCardType == CardType.BARCODE) {
      // Add specific barcode validation if needed
      // For example, check if the barcode is numeric or has the right length
      if (!RegExp(r'^[0-9a-zA-Z]+$').hasMatch(value)) {
        return 'Barcode can only contain numbers and letters';
      }

      if (value.length < 3) {
        return 'Barcode should be at least 3 characters';
      }
    }

    return null;
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }

    if (value.length < 3) {
      return 'Title should be at least 3 characters';
    }

    return null;
  }

  String? _validateDescription(String? value) {
    // Description can be optional, or you can add minimum length requirements
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Description should be at least 5 characters';
    }
    return null;
  }

  // Show success feedback to user
  void _showScanSuccessUI(BuildContext context, String format) {
    // Play haptic feedback
    HapticFeedback.mediumImpact();

    // Show snackbar with scan success message
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format detected successfully!'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: Column(
        children: [
          // Toggle buttons for scan/manual entry
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Scan Barcode'),
                  icon: Icon(Icons.qr_code_scanner),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Manual Entry'),
                  icon: Icon(Icons.keyboard),
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
            child: _isManualEntry ? _buildManualEntryForm() : _buildScanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        // Display detected barcode type if available
        if (_scannedData != null && _detectedFormat.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Detected: $_detectedFormat',
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
                                final format = barcode.format?.toString() ?? '';
                                if (format.toLowerCase().contains("qr")) {
                                  _detectedFormat = 'QR Code';
                                  _selectedCardType = CardType.QR_CODE;
                                } else {
                                  _detectedFormat = 'Barcode';
                                  _selectedCardType = CardType.BARCODE;
                                }

                                // Show success UI
                                _showScanSuccessUI(context, _detectedFormat);
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
                                segments: const [
                                  ButtonSegment<CardType>(
                                    value: CardType.BARCODE,
                                    label: Text('Barcode'),
                                    icon: Icon(Icons.barcode_reader),
                                  ),
                                  ButtonSegment<CardType>(
                                    value: CardType.QR_CODE,
                                    label: Text('QR Code'),
                                    icon: Icon(Icons.qr_code),
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
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter a title for this card',
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateTitle,
                          ),
                          const SizedBox(height: 10),
                          // Add validation for description
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter a description',
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateDescription,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Ensure _scannedData is not null before proceeding
                              if (_scannedData != null &&
                                  _formKey.currentState!.validate()) {
                                Navigator.pop(
                                  context,
                                  CardItem(
                                    title:
                                        _titleController.text.isNotEmpty
                                            ? _titleController.text
                                            : 'New Card',
                                    description:
                                        _descriptionController.text.isNotEmpty
                                            ? _descriptionController.text
                                            : 'Scanned Description',
                                    name: _scannedData!,
                                    cardType: _selectedCardType.name,
                                  ),
                                );
                              } else if (_scannedData == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No data scanned'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Add Card'),
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

  Widget _buildManualEntryForm() {
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
                  const Text('Card Type: '),
                  Expanded(
                    child: SegmentedButton<CardType>(
                      segments: const [
                        ButtonSegment<CardType>(
                          value: CardType.BARCODE,
                          label: Text('Barcode'),
                          icon: Icon(Icons.barcode_reader),
                        ),
                        ButtonSegment<CardType>(
                          value: CardType.QR_CODE,
                          label: Text('QR Code'),
                          icon: Icon(Icons.qr_code),
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
                          ? 'Barcode Value'
                          : 'QR Code Value',
                  hintText:
                      _selectedCardType == CardType.BARCODE
                          ? 'Enter the barcode value'
                          : 'Enter the QR code value',
                  border: const OutlineInputBorder(),
                ),
                validator: _validateBarcode,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for this card',
                  border: OutlineInputBorder(),
                ),
                validator: _validateTitle,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter a description',
                  border: OutlineInputBorder(),
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
                      CardItem(
                        title:
                            _titleController.text.isNotEmpty
                                ? _titleController.text
                                : 'New Card',
                        description:
                            _descriptionController.text.isNotEmpty
                                ? _descriptionController.text
                                : 'Manual Entry',
                        name: _barcodeController.text,
                        cardType: _selectedCardType.name,
                      ),
                    );
                  }
                },
                child: const Text('Add Card'),
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
