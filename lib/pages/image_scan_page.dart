import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';

class DetectedImageCode {
  final String code;
  final CardType type;
  final CodeFormat format;

  const DetectedImageCode({
    required this.code,
    required this.type,
    required this.format,
  });
}

class ImageScanTestOverrides {
  static List<DetectedImageCode>? _nextResults;

  static void queueResults(List<DetectedImageCode> results) {
    _nextResults = results;
  }

  static List<DetectedImageCode>? takeNextResults() {
    final results = _nextResults;
    _nextResults = null;
    return results;
  }

  static void clear() {
    _nextResults = null;
  }
}

CodeFormat _codeFormatFromImageBarcodeFormat(BarcodeFormat format) {
  switch (format) {
    case BarcodeFormat.qrCode:
      return CodeFormat.qrCode;
    case BarcodeFormat.ean13:
      return CodeFormat.ean13;
    case BarcodeFormat.ean8:
      return CodeFormat.ean8;
    case BarcodeFormat.upca:
      return CodeFormat.upcA;
    case BarcodeFormat.upce:
      return CodeFormat.upcE;
    case BarcodeFormat.code128:
      return CodeFormat.code128;
    case BarcodeFormat.code39:
      return CodeFormat.code39;
    case BarcodeFormat.code93:
      return CodeFormat.code93;
    default:
      return CodeFormat.unknown;
  }
}

class ImageScanPage extends StatefulWidget {
  final String imagePath;
  final Function(String code, CardType type, CodeFormat format) onCodeEntered;
  final bool showImagePreview;

  const ImageScanPage({
    super.key,
    required this.imagePath,
    required this.onCodeEntered,
    this.showImagePreview = true,
  });

  @override
  State<ImageScanPage> createState() => _ImageScanPageState();
}

class _ImageScanPageState extends State<ImageScanPage> {
  final TextEditingController _codeController = TextEditingController();
  CardType _selectedType = CardType.qrCode;
  CodeFormat _selectedFormat = CodeFormat.qrCode;
  bool _isScanning = false;
  List<DetectedImageCode> _detectedCodes = const [];
  int _selectedCodeIndex = 0;
  late BarcodeScanner _barcodeScanner;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scanImageForCode();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _scanImageForCode() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      final testResults = ImageScanTestOverrides.takeNextResults();
      final List<DetectedImageCode> detectedCodes;
      if (testResults != null) {
        detectedCodes = testResults;
      } else {
        final file = File(widget.imagePath);
        final inputImage = InputImage.fromFilePath(file.path);
        final barcodes = await _barcodeScanner.processImage(inputImage);
        detectedCodes = barcodes
            .map((barcode) {
              final code = barcode.displayValue ?? barcode.rawValue ?? '';
              final format = _codeFormatFromImageBarcodeFormat(barcode.format);
              return DetectedImageCode(
                code: code,
                type: format.cardType,
                format: format,
              );
            })
            .where((result) => result.code.isNotEmpty)
            .toList();
      }

      if (!mounted) return;
      if (detectedCodes.isNotEmpty) {
        _applyDetectedCodes(detectedCodes);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.codeScannedSuccessfully),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noCodeFoundInImage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        developer.log(
          'Error scanning image: $e',
          name: 'ImageScanPage',
          error: e,
        );
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorScanningImage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _applyDetectedCodes(List<DetectedImageCode> detectedCodes) {
    setState(() {
      _detectedCodes = detectedCodes;
      _selectedCodeIndex = 0;
      _selectDetectedCode(0, notify: false);
    });
  }

  void _selectDetectedCode(int index, {bool notify = true}) {
    final detectedCode = _detectedCodes[index];
    void update() {
      _selectedCodeIndex = index;
      _codeController.text = detectedCode.code;
      _selectedType = detectedCode.type;
      _selectedFormat = detectedCode.format;
    }

    if (notify) {
      setState(update);
    } else {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).scanFromImageTitle),
        actions: [
          TextButton(
            onPressed: _canSave() ? _saveCode : null,
            child: Text(
              AppLocalizations.of(context).save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image display
            if (widget.showImagePreview)
              Container(
                width: double.infinity,
                height: 300,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context).scanFromImageInstructions,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ),

            if (_isScanning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).scanningImage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

            // Code entry form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  if (_detectedCodes.length > 1) ...[
                    DropdownButtonFormField<int>(
                      key: const ValueKey('image_detected_code_selector'),
                      initialValue: _selectedCodeIndex,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).code,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (
                          var index = 0;
                          index < _detectedCodes.length;
                          index++
                        )
                          DropdownMenuItem(
                            value: index,
                            child: Text(
                              '${_detectedCodes[index].code} '
                              '(${_detectedCodes[index].format.displayName})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (index) {
                        if (index != null) _selectDetectedCode(index);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Code type selector
                  Text(
                    AppLocalizations.of(context).cardTypeLabel,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CardType>(
                        value: _selectedType,
                        isExpanded: true,
                        onChanged: (CardType? newValue) {
                          if (newValue == null) return;
                          setState(() {
                            _selectedType = newValue;
                            _selectedFormat = newValue == CardType.qrCode
                                ? CodeFormat.qrCode
                                : CodeFormat.ean13;
                          });
                        },
                        items: CardType.values.map<DropdownMenuItem<CardType>>((
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
                  const SizedBox(height: 16),

                  // Code input field
                  Text(
                    AppLocalizations.of(context).code,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const ValueKey('image_code_field'),
                    controller: _codeController,
                    onChanged: (_) => setState(() {}),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _selectedType == CardType.qrCode
                          ? AppLocalizations.of(context).enterQrCodeValue
                          : AppLocalizations.of(context).enterBarcodeValue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const ValueKey('image_save_button'),
                      onPressed: _canSave() ? _saveCode : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context).save,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    return _codeController.text.trim().isNotEmpty;
  }

  void _saveCode() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      widget.onCodeEntered(code, _selectedType, _selectedFormat);
      Navigator.of(context).pop();
    }
  }
}
