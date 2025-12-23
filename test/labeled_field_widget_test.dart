import 'package:cards/widgets/labeled_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LabeledField shows label and hint', (WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LabeledField(
            label: 'My Label',
            controller: controller,
            hint: 'hint here',
          ),
        ),
      ),
    );

    expect(find.text('My Label'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('hint here'), findsOneWidget);
  });

  testWidgets('LabeledField applies numeric input formatter for barcodes', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LabeledField(
            label: 'Code',
            controller: controller,
            hint: 'digits only',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ),
    );

    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    // Simulate typing alphanumeric content; input formatter should strip letters
    await tester.enterText(field, 'abc123def456');
    // Pump to allow formatters to apply
    await tester.pump();

    expect(controller.text, '123456');
  });
}
