import 'dart:convert';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../helpers/database_helper.dart';
import '../models/card_item.dart';

class CardDetailPage extends StatelessWidget {
  final CardItem card;
  final Function(CardItem)? onDelete;

  const CardDetailPage({super.key, required this.card, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share as JSON',
            onPressed: () async {
              final jsonString = jsonEncode(card.toMap());
              final tempDir = await getTemporaryDirectory();
              final file = File(
                '${tempDir.path}/${card.title.replaceAll(' ', '_')}.json',
              );
              await file.writeAsString(jsonString);
              await Share.shareXFiles([
                XFile(file.path),
              ], text: 'Card: ${card.title}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit card',
            onPressed: () async {
              final updated = await showDialog<CardItem>(
                context: context,
                builder: (ctx) => _EditCardDialog(card: card),
              );
              if (updated != null) {
                await DatabaseHelper().updateCardSortOrders([updated]);
                // Pop this page to force refresh on parent (or use a callback)
                Navigator.of(context).pop();
              }
            },
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete card',
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Delete Card'),
                        content: const Text(
                          'Are you sure you want to delete this card?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              onDelete!(card);
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (card.description.isNotEmpty) ...[
                Text(
                  card.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
              // Text(
              //   'Type: ${card.cardType}',
              //   style: Theme.of(context).textTheme.bodyMedium,
              //   textAlign: TextAlign.center,
              // ),
              // const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return _buildCodeWidget(constraints.maxWidth);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeWidget(double availableWidth) {
    Widget codeInstance;
    double qrSize = availableWidth * 0.85;
    double barcodeWidth = availableWidth * 0.95;
    double barcodeHeight = barcodeWidth * 0.3;

    if (card.cardType == 'BARCODE') {
      codeInstance = BarcodeWidget(
        barcode: Barcode.code128(),
        data: card.name,
        drawText: false,
        color: Colors.black,
        backgroundColor: Colors.transparent,
        width: barcodeWidth,
        height: barcodeHeight,
      );
    } else {
      codeInstance = QrImageView(
        data: card.name,
        version: QrVersions.auto,
        size: qrSize,
        foregroundColor: Colors.black,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: codeInstance,
    );
  }
}

class _EditCardDialog extends StatefulWidget {
  final CardItem card;
  const _EditCardDialog({required this.card});

  @override
  State<_EditCardDialog> createState() => _EditCardDialogState();
}

class _EditCardDialogState extends State<_EditCardDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descController = TextEditingController(text: widget.card.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updated = widget.card.copyWith(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
            );
            // Update in DB
            final db = DatabaseHelper();
            await db.updateCard(updated);
            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
