class Review {
  final String id;
  final String message;
  final String improvements;
  final int rating;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerAvatarUrl;
  final List<String>? services;

  Review({
    required this.id,
    required this.message,
    required this.improvements,
    required this.rating,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
    this.services,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different possible date formats
      DateTime parseDate(dynamic dateValue) {
        if (dateValue == null) return DateTime.now();
        
        if (dateValue is String) {
          if (dateValue.isEmpty) return DateTime.now();
          
          // Try parsing ISO format first
          DateTime? parsed = DateTime.tryParse(dateValue);
          if (parsed != null) return parsed;
          
          // Try other common formats if needed
          return DateTime.now();
        }
        
        return DateTime.now();
      }

      // Handle services list
      List<String>? parseServices(dynamic servicesValue) {
        if (servicesValue == null) return null;
        if (servicesValue is List) {
          return servicesValue.map((e) => e.toString()).toList();
        }
        return null;
      }

      return Review(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        improvements: json['improvements']?.toString() ?? '',
        rating: (json['rating'] is int) ? json['rating'] : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
        createdAt: parseDate(json['createdAt'] ?? json['created_at']),
        reviewerName: json['reviewerName']?.toString() ?? json['reviewer_name']?.toString(),
        reviewerAvatarUrl: json['reviewerAvatarUrl']?.toString() ?? json['reviewer_avatar_url']?.toString(),
        services: parseServices(json['services']),
      );
    } catch (e) {
      print('DEBUG: Error parsing review JSON: $e');
      print('DEBUG: JSON data: $json');
      // Return a default review if parsing fails
      return Review(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? 'unknown',
        message: json['message']?.toString() ?? 'Unable to parse review',
        improvements: json['improvements']?.toString() ?? '',
        rating: 0,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'improvements': improvements,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'reviewerName': reviewerName,
      'reviewerAvatarUrl': reviewerAvatarUrl,
      'services': services,
    };
  }

  @override
  String toString() {
    return 'Review{id: $id, message: ${message.substring(0, message.length > 30 ? 30 : message.length)}${message.length > 30 ? '...' : ''}, rating: $rating, createdAt: $createdAt}';
  }
}