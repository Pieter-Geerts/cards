import 'package:cards/models/card_item.dart';
import 'package:cards/pages/camera_scan_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  group('camera scanner format mapping', () {
    final mappings = <BarcodeFormat, CodeFormat>{
      BarcodeFormat.qrCode: CodeFormat.qrCode,
      BarcodeFormat.ean13: CodeFormat.ean13,
      BarcodeFormat.ean8: CodeFormat.ean8,
      BarcodeFormat.upcA: CodeFormat.upcA,
      BarcodeFormat.upcE: CodeFormat.upcE,
      BarcodeFormat.code128: CodeFormat.code128,
      BarcodeFormat.code39: CodeFormat.code39,
      BarcodeFormat.code93: CodeFormat.code93,
    };

    for (final entry in mappings.entries) {
      test('${entry.key.name} keeps its concrete symbology', () {
        expect(codeFormatFromBarcodeFormat(entry.key), entry.value);
        expect(cardTypeFromBarcodeFormat(entry.key), entry.value.cardType);
      });
    }

    test('unsupported scanner formats remain generic barcodes', () {
      expect(
        codeFormatFromBarcodeFormat(BarcodeFormat.dataMatrix),
        CodeFormat.unknown,
      );
      expect(
        cardTypeFromBarcodeFormat(BarcodeFormat.dataMatrix),
        CardType.barcode,
      );
    });
  });
}
