import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'card_item.dart';

abstract class CodeRenderer {
  Widget renderCode(String data, {double? size, double? width, double? height});

  Widget renderForSharing(String data, {double? size});

  bool validateData(String data);

  String get displayName;
}

class CodeRendererFactory {
  static final Map<CardType, CodeRenderer> _renderers = {
    CardType.qrCode: QRCodeRenderer(),
    CardType.barcode: BarcodeRenderer(),
  };

  /// Gets the appropriate renderer for the given card type
  static CodeRenderer getRenderer(CardType cardType) {
    final renderer = _renderers[cardType];
    if (renderer == null) {
      throw UnsupportedError('No renderer available for card type: $cardType');
    }
    return renderer;
  }

  /// Registers a new renderer for a card type
  /// This allows future extension without modifying existing code
  static void registerRenderer(CardType cardType, CodeRenderer renderer) {
    _renderers[cardType] = renderer;
  }

  /// Gets all supported card types
  static List<CardType> get supportedTypes => _renderers.keys.toList();
}

/// QR Code renderer implementation
class QRCodeRenderer implements CodeRenderer {
  @override
  Widget renderCode(
    String data, {
    double? size,
    double? width,
    double? height,
  }) {
    return QrImageView(
      data: data,
      size: size ?? 200,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        color: Colors.black,
        eyeShape: QrEyeShape.square,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.black,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );
  }

  @override
  Widget renderForSharing(String data, {double? size}) {
    return QrImageView(
      data: data,
      size: size ?? 320,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        color: Colors.black,
        eyeShape: QrEyeShape.square,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.black,
        dataModuleShape: QrDataModuleShape.square,
      ),
    );
  }

  @override
  bool validateData(String data) {
    return data.isNotEmpty;
  }

  @override
  String get displayName => 'QR Code';
}

/// Barcode renderer implementation
class BarcodeRenderer implements CodeRenderer {
  @override
  Widget renderCode(
    String data, {
    double? size,
    double? width,
    double? height,
  }) {
    return bw.BarcodeWidget(
      barcode: bw.Barcode.code128(),
      data: data,
      width: width ?? 200,
      height: height ?? 80,
      backgroundColor: Colors.white,
      color: Colors.black,
      drawText: false,
    );
  }

  @override
  Widget renderForSharing(String data, {double? size}) {
    return bw.BarcodeWidget(
      barcode: bw.Barcode.code128(),
      data: data,
      width: size ?? 320,
      height: 120,
      backgroundColor: Colors.white,
      color: Colors.black,
      drawText: false,
    );
  }

  @override
  bool validateData(String data) {
    // Basic validation for Code 128 barcodes
    return data.isNotEmpty &&
        data.length >= 3 &&
        RegExp(r'^[0-9a-zA-Z]+$').hasMatch(data);
  }

  @override
  String get displayName => 'Barcode';
}
