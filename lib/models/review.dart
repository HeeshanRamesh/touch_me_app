class Review {
  final String id;
  final String message;
  final String improvements;
  final int rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.message,
    required this.improvements,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] ?? json['_id'] ?? '',
    message: json['message'] ?? '',
    improvements: json['improvements'] ?? '',
    rating: json['rating'] ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}
