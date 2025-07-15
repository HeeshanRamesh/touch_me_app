class GiftCard {
  final String id;
  final String giftCardName;
  final double price;
  final String giftCardDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  GiftCard({
    required this.id,
    required this.giftCardName,
    required this.price,
    required this.giftCardDescription,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory GiftCard.fromJson(Map<String, dynamic> json) {
    print("Parsing GiftCard from JSON: $json"); // <-- PRINT for debug
    return GiftCard(
      id: json['id'] ?? '',
      giftCardName: json['giftCardName'] ?? '',
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : (json['price'] as double? ?? 0.0),
      giftCardDescription: json['giftCardDescription'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}
