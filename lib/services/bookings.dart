import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> bookService({
  required String customerId,
  required String salonOwnerId,
  required String saloonServiceId,
  required String date,
  required String time,
  required String token,
  required String ipgTransactionId,
}) async {
  try {
    final url = Uri.parse('http://192.168.8.199:6000/api/bookings');
    print('🌐 Booking service at: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customerId': customerId,
        'salonOwnerId': salonOwnerId,
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
