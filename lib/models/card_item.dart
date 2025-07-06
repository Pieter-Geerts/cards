import 'package:flutter/material.dart';

import 'code_renderer.dart';

enum CardType { qrCode, barcode }

extension CardTypeExtension on CardType {
  String get displayName {
    switch (this) {
      case CardType.qrCode:
        return 'QR Code';
      case CardType.barcode:
        return 'Barcode';
    }
  }

  bool get is2D {
    return switch (this) {
      CardType.qrCode => true,
      CardType.barcode => false,
    };
  }

  bool get is1D => !is2D;

  // Migration helper for converting old database values
  static CardType fromLegacyValue(String value) {
    return switch (value.toUpperCase()) {
      'QR_CODE' => CardType.qrCode,
      'BARCODE' => CardType.barcode,
      _ => CardType.qrCode,
    };
  }
}

class CardItem {
  final int? id;
  final String title;
  final String description;
  final String name;
  final CardType cardType;
  final DateTime createdAt;
  final int sortOrder;
  final String? logoPath;

  CardItem({
    this.id,
    required this.title,
    required this.description,
    required this.name,
    this.cardType = CardType.qrCode,
    DateTime? createdAt,
    required this.sortOrder,
    this.logoPath,
  }) : createdAt = createdAt ?? DateTime.now();

  CardItem.temp({
    required this.title,
    required this.description,
    required this.name,
    this.cardType = CardType.qrCode,
    this.logoPath,
  }) : id = null,
       createdAt = DateTime.now(),
       sortOrder = -1;

  // Helper to check if this is a QR code
  bool get isQrCode => cardType == CardType.qrCode;

  // Helper to check if this is a barcode
  bool get isBarcode => cardType == CardType.barcode;

  // Helper to check if this is a 2D code (QR, Data Matrix, etc.)
  bool get is2D => cardType.is2D;

  // Helper to check if this is a 1D code (traditional barcodes)
  bool get is1D => cardType.is1D;

  /// Gets the appropriate code renderer for this card
  CodeRenderer get codeRenderer => CodeRendererFactory.getRenderer(cardType);

  /// Renders the code widget for display
  Widget renderCode({double? size, double? width, double? height}) {
    return codeRenderer.renderCode(
      name,
      size: size,
      width: width,
      height: height,
    );
  }

  Widget renderForSharing({double? size}) {
    return codeRenderer.renderForSharing(name, size: size);
  }

  bool get isDataValid => codeRenderer.validateData(name);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'name': name,
      'cardType': cardType.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'sortOrder': sortOrder,
      'logoPath': logoPath,
    };
  }

  factory CardItem.fromMap(Map<String, dynamic> map) {
    CardType parsedCardType;
    final cardTypeValue = map['cardType'] as String?;

    if (cardTypeValue == null) {
      parsedCardType = CardType.qrCode;
    } else {
      try {
        parsedCardType = CardType.values.byName(cardTypeValue);
      } catch (e) {
        parsedCardType = CardTypeExtension.fromLegacyValue(cardTypeValue);
      }
    }

    return CardItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      name: map['name'] as String,
      cardType: parsedCardType,
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now(),
      sortOrder: map['sortOrder'] as int? ?? 0,
      logoPath: map['logoPath'] as String?,
    );
  }

  CardItem copyWith({
    int? id,
    String? title,
    String? description,
    String? name,
    CardType? cardType,
    DateTime? createdAt,
    int? sortOrder,
    String? logoPath,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      name: name ?? this.name,
      cardType: cardType ?? this.cardType,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Widget renderCard() {
    return Card(
      child: Column(
        children: [
          if (logoPath != null) ...[
            Image.asset(logoPath!),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Handle button press
            },
            child: Text('Action'),
          ),
        ],
      ),
    );
  }
}
