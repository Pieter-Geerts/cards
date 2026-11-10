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
  static final Map<CodeFormat, CodeRenderer> _renderers = {
    CodeFormat.qrCode: QRCodeRenderer(),
    CodeFormat.ean13: BarcodeRenderer(CodeFormat.ean13),
    CodeFormat.ean8: BarcodeRenderer(CodeFormat.ean8),
    CodeFormat.upcA: BarcodeRenderer(CodeFormat.upcA),
    CodeFormat.upcE: BarcodeRenderer(CodeFormat.upcE),
    CodeFormat.code128: BarcodeRenderer(CodeFormat.code128),
    CodeFormat.code39: BarcodeRenderer(CodeFormat.code39),
    CodeFormat.code93: BarcodeRenderer(CodeFormat.code93),
    CodeFormat.unknown: BarcodeRenderer(CodeFormat.unknown),
  };

  static CodeRenderer getRenderer(Object format) {
    final codeFormat =
        format is CardType
            ? (format == CardType.qrCode ? CodeFormat.qrCode : CodeFormat.ean13)
            : format as CodeFormat;
    return _renderers[codeFormat] ?? _renderers[CodeFormat.unknown]!;
  }

  static List<CardType> get supportedTypes => [
    CardType.qrCode,
    CardType.barcode,
  ];

  static void registerRenderer(Object format, CodeRenderer renderer) {
    final codeFormat =
        format is CardType
            ? (format == CardType.qrCode ? CodeFormat.qrCode : CodeFormat.ean13)
            : format as CodeFormat;
    _renderers[codeFormat] = renderer;
  }

  static List<CodeFormat> get supportedFormats => _renderers.keys.toList();
}

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
  bool validateData(String data) => data.trim().isNotEmpty;

  @override
  String get displayName => 'QR Code';
}

class BarcodeRenderer implements CodeRenderer {
  final CodeFormat format;

  BarcodeRenderer([Object format = CodeFormat.code128])
    : format =
          format is CardType
              ? (format == CardType.qrCode
                  ? CodeFormat.qrCode
                  : CodeFormat.ean13)
              : format as CodeFormat;

  bw.Barcode get _barcode {
    switch (format) {
      case CodeFormat.ean13:
        return bw.Barcode.ean13();
      case CodeFormat.ean8:
        return bw.Barcode.ean8();
      case CodeFormat.upcA:
        return bw.Barcode.upcA();
      case CodeFormat.upcE:
        return bw.Barcode.upcE();
      case CodeFormat.code39:
        return bw.Barcode.code39();
      case CodeFormat.code93:
        return bw.Barcode.code93();
      case CodeFormat.code128:
      case CodeFormat.unknown:
      case CodeFormat.qrCode:
        return bw.Barcode.code128();
    }
  }

  @override
  Widget renderCode(
    String data, {
    double? size,
    double? width,
    double? height,
  }) {
    return bw.BarcodeWidget(
      barcode: _barcode,
      data: data,
      width: width ?? 240,
      height: height ?? 96,
      backgroundColor: Colors.white,
      color: Colors.black,
      drawText: false,
    );
  }

  @override
  Widget renderForSharing(String data, {double? size}) {
    return bw.BarcodeWidget(
      barcode: _barcode,
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
    final value = data.trim();
    switch (format) {
      case CodeFormat.ean13:
        return _validNumericLength(value, 13) && _validEanChecksum(value);
      case CodeFormat.ean8:
        return _validNumericLength(value, 8) && _validEanChecksum(value);
      case CodeFormat.upcA:
        return _validNumericLength(value, 12) && _validEanChecksum(value);
      case CodeFormat.upcE:
        return RegExp(r'^\d{6,8}$').hasMatch(value);
      case CodeFormat.code39:
        return value.isNotEmpty &&
            RegExp(r'^[0-9A-Z. $/+%-]+$').hasMatch(value);
      case CodeFormat.code93:
      case CodeFormat.code128:
      case CodeFormat.unknown:
        return value.length >= 3 &&
            value.length <= 80 &&
            RegExp(r'^[0-9A-Za-z]+$').hasMatch(value);
      case CodeFormat.qrCode:
        return false;
    }
  }

  bool _validNumericLength(String value, int length) =>
      RegExp('^\\d{$length}\$').hasMatch(value);

  bool _validEanChecksum(String value) {
    if (value.length < 2 || !RegExp(r'^\d+$').hasMatch(value)) return false;
    var sum = 0;
    for (var i = 0; i < value.length - 1; i++) {
      final digit = int.parse(value[i]);
      sum += digit * ((value.length - 1 - i).isOdd ? 3 : 1);
    }
    final check = (10 - (sum % 10)) % 10;
    return check == int.parse(value[value.length - 1]);
  }

  @override
  String get displayName =>
      format == CodeFormat.code128 || format == CodeFormat.unknown
          ? 'Barcode'
          : format.displayName;
}
