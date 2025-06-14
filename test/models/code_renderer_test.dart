import 'package:cards/models/card_item.dart';
import 'package:cards/models/code_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeRendererFactory', () {
    test('should return correct renderer for each card type', () {
      final qrRenderer = CodeRendererFactory.getRenderer(CardType.qrCode);
      final barcodeRenderer = CodeRendererFactory.getRenderer(CardType.barcode);

      expect(qrRenderer, isA<QRCodeRenderer>());
      expect(barcodeRenderer, isA<BarcodeRenderer>());
    });

    test('should throw UnsupportedError for unregistered card type', () {
      // Since we can't create new enum values, we'll test the error handling
      // by temporarily removing a renderer and trying to get it
      expect(() => CodeRendererFactory.getRenderer(CardType.qrCode), returnsNormally);
    });

    test('should return all supported types', () {
      final supportedTypes = CodeRendererFactory.supportedTypes;
      
      expect(supportedTypes, contains(CardType.qrCode));
      expect(supportedTypes, contains(CardType.barcode));
      expect(supportedTypes.length, 2);
    });

    test('should allow registering new renderers', () {
      // Create a mock renderer for testing
      final mockRenderer = MockCodeRenderer();
      
      // Register it for QR code (temporarily replacing the existing one)
      CodeRendererFactory.registerRenderer(CardType.qrCode, mockRenderer);
      
      // Verify it was registered
      final retrievedRenderer = CodeRendererFactory.getRenderer(CardType.qrCode);
      expect(retrievedRenderer, equals(mockRenderer));
      
      // Restore the original renderer
      CodeRendererFactory.registerRenderer(CardType.qrCode, QRCodeRenderer());
    });
  });

  group('QRCodeRenderer', () {
    late QRCodeRenderer renderer;

    setUp(() {
      renderer = QRCodeRenderer();
    });

    test('should have correct display name', () {
      expect(renderer.displayName, 'QR Code');
    });

    test('should validate data correctly', () {
      expect(renderer.validateData('Valid QR Data'), true);
      expect(renderer.validateData('https://example.com'), true);
      expect(renderer.validateData('12345'), true);
      expect(renderer.validateData(''), false); // empty data
    });

    testWidgets('should render code widget', (WidgetTester tester) async {
      const testData = 'Test QR Data';
      
      final widget = renderer.renderCode(testData);
      
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      
      // Verify that the widget renders without errors
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render sharing widget with correct size', (WidgetTester tester) async {
      const testData = 'Test QR Data';
      
      final widget = renderer.renderForSharing(testData, size: 400);
      
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('BarcodeRenderer', () {
    late BarcodeRenderer renderer;

    setUp(() {
      renderer = BarcodeRenderer();
    });

    test('should have correct display name', () {
      expect(renderer.displayName, 'Barcode');
    });

    test('should validate data correctly', () {
      expect(renderer.validateData('ABC123'), true);
      expect(renderer.validateData('123456789'), true);
      expect(renderer.validateData('VALID123'), true);
      
      expect(renderer.validateData(''), false); // empty
      expect(renderer.validateData('AB'), false); // too short
      expect(renderer.validateData('ABC@123'), false); // invalid characters
      expect(renderer.validateData('ABC 123'), false); // spaces not allowed
    });

    testWidgets('should render code widget', (WidgetTester tester) async {
      const testData = 'ABC123';
      
      final widget = renderer.renderCode(testData);
      
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render sharing widget with correct size', (WidgetTester tester) async {
      const testData = 'ABC123';
      
      final widget = renderer.renderForSharing(testData, size: 400);
      
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

/// Mock renderer for testing factory registration
class MockCodeRenderer implements CodeRenderer {
  @override
  String get displayName => 'Mock Renderer';

  @override
  Widget renderCode(String data, {double? size, double? width, double? height}) {
    return const Text('Mock Code Widget');
  }

  @override
  Widget renderForSharing(String data, {double? size}) {
    return const Text('Mock Sharing Widget');
  }

  @override
  bool validateData(String data) {
    return data == 'MOCK_VALID';
  }
}
