import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:fl_mlkit_scanning/fl_mlkit_scanning.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile;
import 'package:qr_flutter/qr_flutter.dart';

import '../models/card_item.dart';

enum CardType { BARCODE, QR_CODE }

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage>
    with TickerProviderStateMixin {
  String? _scannedData;
  bool _isManualEntry = false;
  CardType _selectedCardType = CardType.QR_CODE;
  String _detectedFormatString = '';

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

  final FlMlKitScanningController _mlkitController =
      FlMlKitScanningController();

  // Add a focus node for the title field
  final FocusNode _titleFocusNode = FocusNode();

  // Add animation controller for code image
  late final AnimationController _codeImageAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _codeImageFadeAnim = CurvedAnimation(
    parent: _codeImageAnimController,
    curve: Curves.easeOutCubic,
  );
  late final Animation<double> _codeImageScaleAnim = Tween<double>(
    begin: 0.92,
    end: 1.0,
  ).animate(_codeImageFadeAnim);

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
    _codeImageAnimController.dispose();
    super.dispose();
  }

  // Validation functions
  String? _validateBarcode(String? value) {
    final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.validationTitleRequired;
    }
    if (value.length < 3) {
      return l10n.validationTitleMinLength;
    }
    return null;
  }

  String? _validateDescription(String? value) {
    // No validation for description field (optional)
    return null;
  }

  // Show success feedback to user
  void _showScanSuccessUI(BuildContext context, String format) {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.scanSuccessMessage(format)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _isScanning = false;
    });
    _animationController.forward();
    _codeImageAnimController.forward(from: 0); // Animate code image in
    // Autofocus the title field after scan
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          300,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      _titleFocusNode.requestFocus();
    });
  }

  Future<void> _importFromPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    try {
      final bytes = await pickedFile.readAsBytes();
      final AnalysisImageModel? result = await _mlkitController
          .scanningImageByte(bytes);
      if (!mounted) return;
      final barcodes = result?.barcodes;
      if (barcodes != null && barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final typeString = barcode.type.toString().toLowerCase();
        setState(() {
          _scannedData = barcode.value;
          _barcodeController.text = barcode.value ?? '';
          if (typeString.contains('qr')) {
            _selectedCardType = CardType.QR_CODE;
          } else {
            _selectedCardType = CardType.BARCODE;
          }
          _isManualEntry = false;
          _isScanning = false;
        });
        _showScanSuccessUI(
          context,
          typeString.contains('qr') ? 'QR Code' : 'Barcode',
        );
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Import from Photo'),
                content: Text(
                  'No QR code or barcode could be detected in the selected image.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Import from Photo'),
              content: Text('Failed to process the image.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCard),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Import from Photo',
            onPressed: _importFromPhoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input method toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(l10n.scanBarcode),
                  selected: !_isManualEntry,
                  onSelected: (selected) {
                    setState(() {
                      _isManualEntry = false;
                    });
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: Text(l10n.manualEntry),
                  selected: _isManualEntry,
                  onSelected: (selected) {
                    setState(() {
                      _isManualEntry = true;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!_isManualEntry)
              SizedBox(height: 350, child: _buildScanner(l10n))
            else ...[
              Text(
                l10n.manualEntry,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card type toggle
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.barcode),
                            selected: _selectedCardType == CardType.BARCODE,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCardType = CardType.BARCODE;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(l10n.qrCode),
                            selected: _selectedCardType == CardType.QR_CODE,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCardType = CardType.QR_CODE;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText:
                            _selectedCardType == CardType.BARCODE
                                ? l10n.barcodeValue
                                : l10n.qrCodeValue,
                        hintText:
                            _selectedCardType == CardType.BARCODE
                                ? l10n.enterBarcodeValue
                                : l10n.enterQrCodeValue,
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validateBarcode,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        hintText: l10n.titleHint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        hintText: l10n.descriptionHint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: _validateDescription,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
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
                      child: Text(l10n.addCard),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanner(AppLocalizations l10n) {
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
                  l10n.detectedFormat(_detectedFormatString),
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
                  height: _isScanning ? 300 : 220,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isScanning) ...[
                            // Live camera feed
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: mobile.MobileScanner(
                                fit: BoxFit.cover,
                                onDetect: (capture) {
                                  final List<mobile.Barcode> barcodes =
                                      capture.barcodes;
                                  if (barcodes.isNotEmpty && _isScanning) {
                                    final barcode = barcodes.first;
                                    if (barcode.rawValue != null) {
                                      setState(() {
                                        _scannedData = barcode.rawValue;
                                        _barcodeController.text =
                                            _scannedData ?? '';
                                        final formatName =
                                            barcode.format.toString();
                                        if (formatName.toLowerCase().contains(
                                          "qr",
                                        )) {
                                          _detectedFormatString =
                                              l10n.textQrCode;
                                          _selectedCardType = CardType.QR_CODE;
                                        } else {
                                          _detectedFormatString =
                                              l10n.textBarcode;
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
                            ),
                            // Scanner overlay
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
                          ] else if (_scannedData != null) ...[
                            FadeTransition(
                              opacity: _codeImageFadeAnim,
                              child: ScaleTransition(
                                scale: _codeImageScaleAnim,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .white, // Always white background for code
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  width: 220,
                                  height: 220,
                                  child: Center(
                                    child:
                                        _selectedCardType == CardType.QR_CODE
                                            ? Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: QrImageView(
                                                data: _scannedData!,
                                                version: QrVersions.auto,
                                                size: 180,
                                                backgroundColor:
                                                    Colors
                                                        .white, // Ensure white background
                                                foregroundColor:
                                                    Colors.black, // Black code
                                              ),
                                            )
                                            : Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: bw.BarcodeWidget(
                                                barcode: bw.Barcode.code128(),
                                                data: _scannedData!,
                                                drawText: false,
                                                color:
                                                    Colors.black, // Black code
                                                backgroundColor:
                                                    Colors
                                                        .white, // White background
                                                width: 180,
                                                height: 60,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Form section below scanner
                if (_scannedData != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                    child: Text(
                      'Now, give your card a name and description:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_scannedData != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Type: '),
                              SegmentedButton<CardType>(
                                segments: [
                                  ButtonSegment<CardType>(
                                    value: CardType.BARCODE,
                                    label: Text(l10n.barcode),
                                    icon: const Icon(Icons.barcode_reader),
                                  ),
                                  ButtonSegment<CardType>(
                                    value: CardType.QR_CODE,
                                    label: Text(l10n.qrCode),
                                    icon: const Icon(Icons.qr_code),
                                  ),
                                ],
                                selected: {_selectedCardType},
                                onSelectionChanged:
                                    null, // Disable toggles after detection
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return Theme.of(
                                              context,
                                            ).disabledColor;
                                          }
                                          return null;
                                        },
                                      ),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                          if (states.contains(
                                            MaterialState.disabled,
                                          )) {
                                            return Theme.of(
                                              context,
                                            ).colorScheme.surfaceVariant;
                                          }
                                          return null;
                                        },
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            decoration: InputDecoration(
                              labelText: l10n.title,
                              hintText:
                                  l10n.titleHint.isNotEmpty
                                      ? l10n.titleHint
                                      : 'e.g., Starbucks Rewards',
                              border: const OutlineInputBorder(),
                            ),
                            validator: _validateTitle,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: l10n.description,
                              hintText:
                                  l10n.descriptionHint.isNotEmpty
                                      ? l10n.descriptionHint
                                      : 'Optional notes, e.g., loyalty program, expiry date',
                              border: const OutlineInputBorder(),
                            ),
                            validator: _validateDescription,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: () {
                              if (_scannedData != null &&
                                  _formKey.currentState!.validate()) {
                                Navigator.pop(
                                  context,
                                  CardItem.temp(
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
                                  SnackBar(content: Text(l10n.noDataScanned)),
                                );
                              }
                            },
                            child: Text(l10n.addCard),
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
}
