// services/bookings.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:touch_me/models/booking.dart';

Future<Map<String, dynamic>> bookService({
  required String customerId,
  required String merchantId, // Renamed from salonOwnerId
  required String saloonServiceId,
  required String date,
  required String time,
  required String token,
  required String ipgTransactionId,
}) async {
  try {
    final url = Uri.parse('http://api.touchmeapp.com/api/bookings');
    print('🌐 Booking service at: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customerId': customerId,
        'merchantId': merchantId, // Updated to merchantId
        'saloonServiceId': saloonServiceId,
        'date': date,
        'time': time,
        'ipgTransactionId': ipgTransactionId,
      }),
    );

    print('✅ Response Status: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to book service. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  } catch (e, stackTrace) {
    print('❌ Error booking service: $e\nStackTrace: $stackTrace');
    throw Exception('Error booking service: $e');
  }
}

Future<List<Booking>> fetchMerchantBookings(String token) async {
  final url = Uri.parse('http://api.touchmeapp.com/api/bookings/my/bookings');
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final bookings = data['bookings'] as List<dynamic>;
    return bookings.map((b) => Booking.fromJson(b)).toList();
  } else {
    throw Exception('Failed to fetch bookings');
  }
}

Future<List<Booking>> fetchCustomerBookings(String token) async {
  final url = Uri.parse(
    'http://api.touchmeapp.com/api/bookings/my-customer-bookings',
  );
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final bookings = data['bookings'] as List<dynamic>;
    return bookings.map((b) => Booking.fromJson(b)).toList();
  } else {
    throw Exception('Failed to fetch customer bookings');
  }
}
