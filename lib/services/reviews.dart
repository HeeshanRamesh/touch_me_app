import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';

Future<List<Review>> fetchReviewsByMerchant(
  String merchantId,
  String token,
) async {
  try {
    print('DEBUG: Fetching reviews for merchant: $merchantId');
    final response = await http.get(
      Uri.parse('http://api.touchmeapp.com/api/reviews/merchant/$merchantId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('DEBUG: Fetch reviews response status: ${response.statusCode}');
    print('DEBUG: Fetch reviews response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        print('DEBUG: Empty response body, returning empty list');
        return [];
      }
      
      final dynamic decodedData = json.decode(responseBody);
      if (decodedData is List) {
        return decodedData.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
      } else if (decodedData is Map && decodedData.containsKey('data')) {
        final List data = decodedData['data'] as List;
        return data.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        print('DEBUG: Unexpected response format: $decodedData');
        return [];
      }
    } else {
      print('DEBUG: Failed to fetch reviews. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load reviews: ${response.statusCode}');
    }
  } catch (e) {
    print('DEBUG: Error in fetchReviewsByMerchant: $e');
    throw Exception('Failed to load reviews: $e');
  }
}

Future<bool> addReview({
  required String merchantId,
  required String token,
  required String message,
  required String improvements,
  required int rating,
}) async {
  try {
    print('DEBUG: Adding review for merchant: $merchantId');
    print('DEBUG: Review data - Rating: $rating, Message: "${message.substring(0, message.length > 50 ? 50 : message.length)}${message.length > 50 ? '...' : ''}"');
    
    final requestBody = {
      'message': message.trim(),
      'improvements': improvements.trim(),
      'rating': rating,
    };
    
    print('DEBUG: Request body: ${jsonEncode(requestBody)}');
    
    final response = await http.post(
      Uri.parse('http://api.touchmeapp.com/api/reviews/$merchantId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );
    
    print('DEBUG: Add review response status: ${response.statusCode}');
    print('DEBUG: Add review response body: ${response.body}');
    print('DEBUG: Add review response headers: ${response.headers}');
    
    // Check for successful status codes (201, 200, or 202)
    if (response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 202) {
      print('DEBUG: Review added successfully');
      return true;
    } else {
      print('DEBUG: Failed to add review. Status: ${response.statusCode}');
      print('DEBUG: Error response: ${response.body}');
      return false;
    }
  } catch (e) {
    print('DEBUG: Error in addReview: $e');
    return false;
  }
}