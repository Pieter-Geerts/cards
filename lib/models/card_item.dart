class CardItem {
  final int? id; // Add an ID for database purposes
  final String title;
  final String description;
  final String name;
  final String cardType; // Added cardType property

  CardItem({
    this.id,
    required this.title,
    required this.description,
    required this.name,
    this.cardType = 'QR_CODE', // Default to QR_CODE
  });

  // Convert a CardItem to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'name': name,
      'cardType': cardType,
    };
  }

  // Create a CardItem from a Map retrieved from the database
  factory CardItem.fromMap(Map<String, dynamic> map) {
    return CardItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      name: map['name'],
      cardType: map['cardType'] ?? 'QR_CODE', // Handle null for older records
    );
  }
}
