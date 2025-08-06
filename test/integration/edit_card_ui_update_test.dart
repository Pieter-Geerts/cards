import 'package:cards/models/card_item.dart';
import 'package:cards/widgets/logo_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_helper.dart';

/// Widget wrapper for testing individual components with proper Material context
class TestableWidget extends StatelessWidget {
  final Widget child;

  const TestableWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}

/// Simple card display widget for testing
class TestCardDisplayWidget extends StatelessWidget {
  final CardItem card;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TestCardDisplayWidget({
    Key? key,
    required this.card,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(card.title),
        Text(card.name),
        if (card.description.isNotEmpty) Text(card.description),
        LogoAvatarWidget(logoKey: card.logoPath, title: card.title),
        Row(
          children: [
            if (onEdit != null)
              ElevatedButton(onPressed: onEdit, child: const Text('Edit')),
            if (onDelete != null)
              ElevatedButton(onPressed: onDelete, child: const Text('Delete')),
          ],
        ),
      ],
    );
  }
}

/// Simple card edit form widget for testing
class TestCardEditWidget extends StatefulWidget {
  final CardItem card;
  final void Function(CardItem)? onSave;
  final VoidCallback? onCancel;

  const TestCardEditWidget({
    Key? key,
    required this.card,
    this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<TestCardEditWidget> createState() => _TestCardEditWidgetState();
}

class _TestCardEditWidgetState extends State<TestCardEditWidget> {
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _nameController = TextEditingController(text: widget.card.name);
    _descController = TextEditingController(text: widget.card.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveCard() {
    final updatedCard = CardItem(
      id: widget.card.id,
      title: _titleController.text,
      name: _nameController.text,
      description: _descController.text,
      cardType: widget.card.cardType,
      sortOrder: widget.card.sortOrder,
      logoPath: widget.card.logoPath,
    );
    widget.onSave?.call(updatedCard);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name/Code'),
        ),
        TextField(
          controller: _descController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        Row(
          children: [
            ElevatedButton(onPressed: _saveCard, child: const Icon(Icons.save)),
            if (widget.onCancel != null)
              ElevatedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Fast integration tests using mocks and simple test widgets
void main() {
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
  });

  tearDown(() {
    reset(mockDatabaseHelper);
  });

  group('Edit Card UI Update Integration Test', () {
    testWidgets(
      'TestCardDisplayWidget shows card information correctly',
      (WidgetTester tester) async {
        final testCard = CardItem(
          id: 1,
          title: 'Test Card Display',
          description: 'Test description',
          name: 'DISPLAY123',
          cardType: CardType.barcode,
          sortOrder: 0,
        );

        await tester.pumpWidget(
          TestableWidget(child: TestCardDisplayWidget(card: testCard)),
        );
        await tester.pumpAndSettle();

        // Verify card information is displayed
        expect(find.text('Test Card Display'), findsOneWidget);
        expect(find.text('DISPLAY123'), findsOneWidget);
        expect(find.text('Test description'), findsOneWidget);
      },
      tags: ['integration', 'fast'],
    );

    testWidgets(
      'TestCardEditWidget correctly updates card data through callback',
      (WidgetTester tester) async {
        CardItem? savedCard;
        bool onSaveCalled = false;

        final testCard = CardItem(
          id: 1,
          title: 'Original Title',
          description: 'Original description',
          name: 'ORIGINAL123',
          cardType: CardType.barcode,
          sortOrder: 0,
        );

        await tester.pumpWidget(
          TestableWidget(
            child: TestCardEditWidget(
              card: testCard,
              onSave: (card) {
                onSaveCalled = true;
                savedCard = card;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify form is populated with original data
        expect(find.text('Original Title'), findsOneWidget);
        expect(find.text('ORIGINAL123'), findsOneWidget);

        // Update the title field
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, 'Updated Title');
        await tester.pumpAndSettle();

        // Update the name field
        final nameField = find.byType(TextField).at(1);
        await tester.enterText(nameField, 'UPDATED456');
        await tester.pumpAndSettle();

        // Save the changes
        final saveButton = find.byIcon(Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify callback was called with updated data
        expect(onSaveCalled, isTrue);
        expect(savedCard, isNotNull);
        expect(savedCard!.title, 'Updated Title');
        expect(savedCard!.name, 'UPDATED456');
        expect(savedCard!.description, 'Original description');
      },
      tags: ['integration', 'fast'],
    );

    testWidgets(
      'Editing workflow from display to edit and back to display',
      (WidgetTester tester) async {
        CardItem? updatedCard;
        bool editMode = false;

        final originalCard = CardItem(
          id: 1,
          title: 'Original Card',
          description: 'Original description',
          name: 'ORIGINAL123',
          cardType: CardType.barcode,
          sortOrder: 0,
        );

        await tester.pumpWidget(
          TestableWidget(
            child: StatefulBuilder(
              builder: (context, setState) {
                return editMode
                    ? TestCardEditWidget(
                      card: updatedCard ?? originalCard,
                      onSave: (card) {
                        setState(() {
                          updatedCard = card;
                          editMode = false;
                        });
                      },
                      onCancel: () {
                        setState(() {
                          editMode = false;
                        });
                      },
                    )
                    : TestCardDisplayWidget(
                      card: updatedCard ?? originalCard,
                      onEdit: () {
                        setState(() {
                          editMode = true;
                        });
                      },
                    );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify we start in display mode
        expect(find.text('Original Card'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);

        // Tap edit button
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Should now be in edit mode
        expect(find.byType(TextField), findsNWidgets(3));

        // Update the title
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, 'Updated Card');
        await tester.pumpAndSettle();

        // Save changes
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();

        // Should be back in display mode with updated data
        expect(find.text('Updated Card'), findsOneWidget);
        expect(find.text('ORIGINAL123'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      },
      tags: ['integration', 'fast'],
    );
  });
}
