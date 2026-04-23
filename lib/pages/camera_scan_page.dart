import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../models/card_item.dart';

class CameraScanTestResult {
  final String code;
  final BarcodeFormat format;

  const CameraScanTestResult({required this.code, required this.format});
}

class CameraScanTestOverrides {
  static CameraScanTestResult? _nextResult;

  static void queueResult(CameraScanTestResult result) {
    _nextResult = result;
  }

  static CameraScanTestResult? takeNextResult() {
    final result = _nextResult;
    _nextResult = null;
    return result;
  }

  static void clear() {
    _nextResult = null;
  }
}

CardType cardTypeFromBarcodeFormat(BarcodeFormat format) {
  switch (format) {
    case BarcodeFormat.qrCode:
      return CardType.qrCode;
    case BarcodeFormat.ean13:
    case BarcodeFormat.ean8:
    case BarcodeFormat.upcA:
    case BarcodeFormat.upcE:
    case BarcodeFormat.code128:
    case BarcodeFormat.code39:
    case BarcodeFormat.code93:
      return CardType.barcode;
    default:
      return CardType.qrCode;
  }
}

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testResult = CameraScanTestOverrides.takeNextResult();
      if (!mounted || testResult == null) return;
      _handleDetectedCode(testResult.code, testResult.format);
    });
  }

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
        _handleDetectedCode(code, barcode.format);
      }
    }
  }

  void _handleDetectedCode(String code, BarcodeFormat format) {
    if (_isCodeScanned || code.isEmpty) return;

    setState(() {
      _isCodeScanned = true;
    });

    widget.onCodeScanned(code, cardTypeFromBarcodeFormat(format));
    if (mounted) Navigator.of(context).pop();
  }

  void _toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      // Query the actual torch state if available; otherwise toggle local state
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Failed to toggle torch: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to toggle flash')));
    }
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
            key: const ValueKey('flash_toggle_button'),
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
          MobileScanner(
            key: const ValueKey('camera_preview'),
            controller: cameraController,
            onDetect: _onDetect,
          ),

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
