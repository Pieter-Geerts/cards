import 'dart:io';

import 'package:flutter/material.dart';

import '../models/card_item.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          // Image display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
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

          // Code entry form
          Expanded(
            flex: 1,
            child: Padding(
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

                  const Spacer(),

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
          ),
        ],
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
