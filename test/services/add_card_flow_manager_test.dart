import 'package:cards/l10n/app_localizations.dart';
import 'package:cards/pages/camera_scan_page.dart';
import 'package:cards/services/add_card_flow_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Widget _harness(AddCardFlowMode mode) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () =>
                AddCardFlowManager.showAddCardFlow(context, mode: mode),
            child: const Text('Start'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(CameraScanTestOverrides.clear);

  testWidgets('selection mode opens the canonical entry page', (tester) async {
    await tester.pumpWidget(_harness(AddCardFlowMode.selection));

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('scan_barcode_button')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('scan_from_photo_button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('manual_entry_button')), findsOneWidget);
  });

  testWidgets('manual mode opens the manual card form directly', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(AddCardFlowMode.manual));

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('card_type_dropdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('code_field')), findsOneWidget);
  });

  testWidgets('scan mode forwards a detected code to the card form', (
    tester,
  ) async {
    CameraScanTestOverrides.queueResult(
      const CameraScanTestResult(
        code: '4006381333931',
        format: BarcodeFormat.ean13,
      ),
    );
    await tester.pumpWidget(_harness(AddCardFlowMode.scan));

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('code_field')), findsOneWidget);
    expect(find.text('4006381333931'), findsOneWidget);
  });

  testWidgets('camera manual fallback opens the manual card form', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(AddCardFlowMode.scan));

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('camera_manual_entry_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('card_type_dropdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('code_field')), findsOneWidget);
  });
}
