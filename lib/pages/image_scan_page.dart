import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';

class ImageScanPage extends StatefulWidget {
  final String imagePath;
  final Function(String code, CardType type) onCodeEntered;

  const ImageScanPage({
    super.key,
    required this.imagePath,
    required this.onCodeEntered,
  });

  @override
  State<ImageScanPage> createState() => _ImageScanPageState();
}

class _ImageScanPageState extends State<ImageScanPage> {
  final TextEditingController _codeController = TextEditingController();
  CardType _selectedType = CardType.qrCode;
  bool _isScanning = false;
  late BarcodeScanner _barcodeScanner;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner();
    _scanImageForCode();
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
      final file = File(widget.imagePath);
      final inputImage = InputImage.fromFilePath(file.path);

      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty && mounted) {
        final barcode = barcodes.first;
        final code = barcode.displayValue ?? barcode.rawValue ?? '';

        if (code.isNotEmpty) {
          // Determine the type based on barcode format
          late CardType detectedType;
          switch (barcode.format) {
            case BarcodeFormat.qrCode:
              detectedType = CardType.qrCode;
              break;
            default:
              detectedType = CardType.barcode;
          }

          setState(() {
            _codeController.text = code;
            _selectedType = detectedType;
          });

          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.codeScannedSuccessfully),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else if (mounted) {
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
        debugPrint('Error scanning image: $e');
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
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
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
                          setState(() => _selectedType = newValue!);
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
                  const SizedBox(height: 16),

                  // Code input field
                  Text(
                    AppLocalizations.of(context).code,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeController,
                    onChanged: (_) => setState(() {}),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          _selectedType == CardType.qrCode
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
      widget.onCodeEntered(code, _selectedType);
      Navigator.of(context).pop();
    }
  }
}
