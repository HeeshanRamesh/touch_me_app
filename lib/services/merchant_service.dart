import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/merchant.dart';

Future<List<Merchant>> fetchMerchants(String token) async {
  final response = await http.get(
    Uri.parse('http://api.touchmeapp.com/api/merchants'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('ℹ️ Full API response: $data');

    // Handle different response structures
    if (data is List) {
      return data.map((json) => Merchant.fromJson(json)).toList();
    } else if (data['merchants'] is List) {
      return (data['merchants'] as List)
          .map((json) => Merchant.fromJson(json))
          .toList();
    } else if (data['data'] is List) {
      return (data['data'] as List)
          .map((json) => Merchant.fromJson(json))
          .toList();
    } else {
      throw Exception('Unexpected API response format');
    }
  } else {
    throw Exception('Failed to load merchants. Status: ${response.statusCode}');
  }
}
