import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/card_item.dart';

class CardDetailPage extends StatelessWidget {
  final CardItem card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(card.title)),
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
