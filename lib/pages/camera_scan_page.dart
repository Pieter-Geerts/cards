import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';

class CameraScanPage extends StatefulWidget {
  final Function(String code, CardType type) onCodeScanned;

  const CameraScanPage({super.key, required this.onCodeScanned});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isCodeScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (_isCodeScanned) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final code = barcode.rawValue ?? '';

      if (code.isNotEmpty) {
        setState(() {
          _isCodeScanned = true;
        });

        // Determine card type based on barcode format
        CardType cardType = CardType.qrCode;
        switch (barcode.format) {
          case BarcodeFormat.qrCode:
            cardType = CardType.qrCode;
            break;
          case BarcodeFormat.ean13:
          case BarcodeFormat.ean8:
          case BarcodeFormat.upcA:
          case BarcodeFormat.upcE:
            cardType = CardType.barcode;
            break;
          case BarcodeFormat.code128:
          case BarcodeFormat.code39:
          case BarcodeFormat.code93:
            cardType = CardType.barcode;
            break;
          default:
            cardType = CardType.qrCode;
        }

        // Return the scanned code
        Navigator.of(context).pop();
        widget.onCodeScanned(code, cardType);
      }
    }
  }

  void _toggleFlash() async {
    await cameraController.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context).scanCode,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Scanning overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(179),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppLocalizations.of(context).scanInstructionsTooltip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Manual entry button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can add manual entry navigation here if needed
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).manualEntryFull,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
