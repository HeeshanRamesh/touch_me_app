class PurchasedGiftCard {
  final String id;
  final String code;
  final double value;
  final String status;
  final DateTime expiryDate;
  final String giftCardName;
  final String description;
  final double price;
  final String merchantName;

  PurchasedGiftCard({
    required this.id,
    required this.code,
    required this.value,
    required this.status,
    required this.expiryDate,
    required this.giftCardName,
    required this.description,
    required this.price,
    required this.merchantName,
  });

  factory PurchasedGiftCard.fromJson(Map<String, dynamic> json) {
    return PurchasedGiftCard(
      id: json['id'] ?? json['_id'] ?? '',
      code: json['code'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? '',
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ?? DateTime.now(),
      giftCardName: json['giftCard']?['giftCardName'] ?? '',
      description: json['giftCard']?['giftCardDescription'] ?? '',
      price: (json['giftCard']?['price'] as num?)?.toDouble() ?? 0,
      merchantName: json['giftCard']?['merchant']?['outlet']?['name'] ?? '',
    );
  }
}
