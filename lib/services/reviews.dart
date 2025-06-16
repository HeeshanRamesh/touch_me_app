import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';

Future<List<Review>> fetchReviewsByMerchant(
  String merchantId,
  String token,
) async {
  final response = await http.get(
    Uri.parse('http://api.touchmeapp.com/api/reviews/merchant/$merchantId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((e) => Review.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load reviews');
  }
}

Future<bool> addReview({
  required String merchantId,
  required String token,
  required String message,
  required String improvements,
  required int rating,
}) async {
  final response = await http.post(
    Uri.parse('http://api.touchmeapp.com/api/reviews/$merchantId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'message': message,
      'improvements': improvements,
      'rating': rating,
    }),
  );
  return response.statusCode == 201;
}
