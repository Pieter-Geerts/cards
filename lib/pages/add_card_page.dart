import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/card_item.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  String? _scannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR/Barcode')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() {
                    _scannedData = barcodes.first.rawValue;
                  });
                }
              },
            ),
          ),
          if (_scannedData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    CardItem(
                      title: 'New Card',
                      description: 'Scanned Description',
                      name: _scannedData!,
                    ),
                  );
                },
                child: const Text('Add Card'),
              ),
            ),
        ],
      ),
    );
  }
}
