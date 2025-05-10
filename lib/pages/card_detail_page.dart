import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/card_item.dart';

class CardDetailPage extends StatelessWidget {
  final CardItem card;
  final Function(CardItem)? onDelete; // This is correctly defined as nullable

  const CardDetailPage({
    super.key,
    required this.card,
    this.onDelete, // This remains optional
  });

  @override
  Widget build(BuildContext context) {
    // Add debug print to verify callback is received
    print('onDelete is ${onDelete != null ? "provided" : "null"}');

    return Scaffold(
      appBar: AppBar(
        title: Text(card.title),
        actions: [
          // The conditional check is correct, but let's ensure it works
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete card',
              onPressed: () {
                // Show confirmation dialog
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(card.description),
            const SizedBox(height: 10),
            // Display card type
            Text(
              'Type: ${card.cardType}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Container(alignment: Alignment.center, child: _buildCodeWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeWidget() {
    // Check if the card type is BARCODE or QR_CODE
    if (card.cardType == 'BARCODE') {
      return SizedBox(
        height: 100,
        width: 300,
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: card.name,
          drawText: false,
        ),
      );
    } else {
      // Default to QR code (for 'QR_CODE' or any other value)
      return QrImageView(
        data: card.name,
        version: QrVersions.auto,
        size: 200.0,
      );
    }
  }
}
