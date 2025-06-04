// services/services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';

Future<List<Service>> fetchServices(String token) async {
  final response = await http.get(
    Uri.parse('http://192.168.8.199:6000/api/services'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ✅ Include token
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Service.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load services. Status: ${response.statusCode}');
  }
}


Future<List<Service>> fetchServicesByMerchant(
  String merchantId,
  String token,
) async {
  try {
    final url = Uri.parse(
      'http://192.168.8.199:6000/api/services/merchant/$merchantId',
    );
    print('🌐 Calling: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('✅ Response Status: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Log the raw data for debugging
      print('ℹ️ Parsed JSON data: $data');

      // Handle different response formats
      List<dynamic> services;
      if (data is List) {
        services = data;
      } else if (data is Map &&
          (data['services'] is List || data['data'] is List)) {
        services = data['services'] ?? data['data'] ?? [];
      } else {
        print('⚠️ Unexpected response format: $data');
        return [];
      }

      if (services.isEmpty) {
        print('⚠️ No services found for merchant ID: $merchantId');
      }

      return services
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      print('ℹ️ No services found for merchant (404)');
      return [];
    } else {
      throw Exception(
        'Failed to load services. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  } catch (e, stackTrace) {
    print('❌ Error fetching services: $e\nStackTrace: $stackTrace');
    return [];
  }
}

Future<http.Response> addServiceForMerchant({
  required String merchantId,
  required String token,
  required Service service,
}) async {
  final url = Uri.parse('http://192.168.8.199:6000/api/services/$merchantId');

  final Map<String, dynamic> serviceData = {
    'serviceName': service.serviceName,
    'serviceDescription': service.serviceDescription,
    'price': service.price,
    'image': service.image,
    'isActive': service.isActive,
  };

  return await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(serviceData),
  );
}





