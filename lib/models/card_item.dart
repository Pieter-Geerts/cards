class CardItem {
  final int? id;
  final String title;
  final String description;
  final String name;
  final String cardType;
  final DateTime createdAt;
  final int sortOrder;

  CardItem({
    this.id,
    required this.title,
    required this.description,
    required this.name,
    this.cardType = 'QR_CODE',
    DateTime? createdAt,
    required this.sortOrder,
  }) : createdAt = createdAt ?? DateTime.now();

  // Temporary constructor for AddCardPage to return data without sortOrder yet.
  // HomePage will use this data to create the final CardItem with a sortOrder.
  CardItem.temp({
    required this.title,
    required this.description,
    required this.name,
    this.cardType = 'QR_CODE',
  }) : id = null,
       createdAt = DateTime.now(),
       sortOrder = -1; // Placeholder, will be overwritten by HomePage

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'name': name,
      'cardType': cardType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'sortOrder': sortOrder,
    };
  }

  factory CardItem.fromMap(Map<String, dynamic> map) {
    return CardItem(
      id: map['id'],
      title: map['title'] ?? '', // Provide default for title if null
      description:
          map['description'] ?? '', // Provide default for description if null
      name: map['name'] ?? '', // Provide default for name if null
      cardType: map['cardType'] ?? 'QR_CODE',
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : DateTime.now(), // Default for older records
      // Provide a sensible default for sortOrder if it's missing,
      // e.g., using id or a timestamp-based value if id is also null.
      // Using 0 as a fallback if id is also null.
      sortOrder: map['sortOrder'] ?? (map['id'] ?? map['createdAt'] ?? 0),
    );
  }

  CardItem copyWith({
    int? id,
    String? title,
    String? description,
    String? name,
    String? cardType,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      name: name ?? this.name,
      cardType: cardType ?? this.cardType,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
