import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete card',
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Delete Card'), // Consider localizing
                        content: const Text(
                          'Are you sure you want to delete this card?', // Consider localizing
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'), // Consider localizing
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              onDelete!(card);
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Delete', // Consider localizing
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
        // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center content horizontally
            children: [
              if (card.description.isNotEmpty) ...[
                Text(
                  card.description,
                  textAlign: TextAlign.center, // Center text
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Type: ${card.cardType}', // Consider localizing 'Type:'
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Consistent spacing
              // Use LayoutBuilder to get available width for the code widget
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
    // Determine size based on availableWidth
    // For QR codes, aim for a large square, e.g., 80-85% of screen width.
    // For Barcodes, aim for width of ~90-95%, height proportional.
    double qrSize = availableWidth * 0.85;
    double barcodeWidth = availableWidth * 0.95;
    // Adjust barcode height for a typical aspect ratio, e.g., 1:3 or 1:2.5
    double barcodeHeight = barcodeWidth * 0.3;

    if (card.cardType == 'BARCODE') {
      codeInstance = BarcodeWidget(
        barcode: Barcode.code128(),
        data: card.name,
        drawText: false,
        color: Colors.black,
        backgroundColor:
            Colors.transparent, // BarcodeWidget itself is transparent
        width: barcodeWidth,
        height: barcodeHeight,
      );
    } else {
      // Default to QR code (for 'QR_CODE' or any other value)
      codeInstance = QrImageView(
        data: card.name,
        version: QrVersions.auto,
        size: qrSize,
        foregroundColor: Colors.black,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 20.0,
      ), // Margin around the code's container
      color:
          Colors.white, // Set the background color for the code area to white
      padding: const EdgeInsets.all(
        16.0,
      ), // Padding inside the white box, around the code
      child: codeInstance,
    );
  }
}
