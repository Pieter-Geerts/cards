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
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: QrImageView(
                data: card.name,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
