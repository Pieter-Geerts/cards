class CardItem {
  final int? id;
  final String title;
  final String description;
  final String name;
  final String cardType;
  final DateTime createdAt;
  final int sortOrder;
  final String? logoPath;

  CardItem({
    this.id,
    required this.title,
    required this.description,
    required this.name,
    this.cardType = 'QR_CODE',
    DateTime? createdAt,
    required this.sortOrder,
    this.logoPath,
  }) : createdAt = createdAt ?? DateTime.now();

  // Temporary constructor for AddCardPage to return data without sortOrder yet.
  // HomePage will use this data to create the final CardItem with a sortOrder.
  CardItem.temp({
    required this.title,
    required this.description,
    required this.name,
    this.cardType = 'QR_CODE',
    this.logoPath,
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
      'logoPath': logoPath,
    };
  }

  factory CardItem.fromMap(Map<String, dynamic> map) {
    return CardItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      name: map['name'] as String,
      cardType: map['cardType'] as String? ?? 'QR_CODE',
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
    String? cardType,
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
}
