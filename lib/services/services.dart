// services/services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';

Future<List<Service>> fetchServices(String token) async {
  final response = await http.get(
    Uri.parse('http://api.touchmeapp.com/api/services'),
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

// New function to fetch services by service name/category
Future<List<Service>> fetchServicesByCategory(
  String serviceName,
  String token,
) async {
  try {
    final url = Uri.parse(
      'http://api.touchmeapp.com/api/services/category/$serviceName',
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
      print('ℹ️ Parsed JSON data: $data');

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

      // Filter services by name if backend doesn't support category filtering
      final filteredServices = services.where((s) {
        final service = Service.fromJson(s as Map<String, dynamic>);
        return service.serviceName.toLowerCase().contains(serviceName.toLowerCase()) ||
               _isServiceMatchingCategory(service.serviceName, serviceName);
      }).toList();

      if (filteredServices.isEmpty) {
        print('⚠️ No services found for category: $serviceName');
      }

      return filteredServices
          .map((s) => Service.fromJson(s as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      print('ℹ️ No services found for category (404)');
      return [];
    } else {
      throw Exception(
        'Failed to load services. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  } catch (e, stackTrace) {
    print('❌ Error fetching services by category: $e\nStackTrace: $stackTrace');
    // Fallback: fetch all services and filter locally
    return await fetchServicesAndFilterLocally(serviceName, token);
  }
}

// Fallback function to filter services locally if API doesn't support category filtering
Future<List<Service>> fetchServicesAndFilterLocally(
  String serviceName,
  String token,
) async {
  try {
    final allServices = await fetchServices(token);
    
    final filteredServices = allServices.where((service) {
      return service.serviceName.toLowerCase().contains(serviceName.toLowerCase()) ||
             _isServiceMatchingCategory(service.serviceName, serviceName);
    }).toList();

    print('ℹ️ Filtered ${filteredServices.length} services for category: $serviceName');
    return filteredServices;
  } catch (e) {
    print('❌ Error in fallback filtering: $e');
    return [];
  }
}

// Helper function to match service names with categories
bool _isServiceMatchingCategory(String serviceName, String categoryName) {
  final service = serviceName.toLowerCase();
  final category = categoryName.toLowerCase();
  
  // Define category mappings
  final categoryMappings = {
    'haircut & styling - ladies': ['haircut', 'hair styling', 'ladies hair', 'women hair'],
    'haircut & styling - gents': ['haircut', 'hair styling', 'men hair', 'gents hair', 'male hair'],
    'haircut & styling - kids': ['kids hair', 'children hair', 'child haircut'],
    'haircut & styling - adults': ['adult hair', 'haircut', 'hair styling'],
    'massage': ['massage', 'body massage', 'therapeutic massage', 'relaxation'],
    'bridal': ['bridal', 'wedding', 'bride makeup', 'bridal package'],
    'tattoo & piercing': ['tattoo', 'piercing', 'body art', 'ink'],
    'facials & skincare': ['facial', 'skincare', 'skin treatment', 'face treatment'],
    'hair removal': ['hair removal', 'waxing', 'laser hair', 'threading'],
    'nails': ['nail', 'manicure', 'pedicure', 'nail art', 'nail polish'],
    'eyebrow & eyelashes': ['eyebrow', 'eyelash', 'brow', 'lash', 'eyebrow threading'],
    'injectable & fillers': ['injectable', 'filler', 'botox', 'dermal filler'],
    'makeup': ['makeup', 'cosmetics', 'face makeup', 'beauty'],
    'dressing': ['dressing', 'styling', 'wardrobe', 'fashion'],
    'pedicure & manicure': ['pedicure', 'manicure', 'nail care', 'foot care'],
    'door step service': ['door step', 'home service', 'mobile service', 'at home'],
  };

  // Check if the service matches any keywords for the category
  final keywords = categoryMappings[category] ?? [category];
  
  return keywords.any((keyword) => service.contains(keyword));
}

Future<List<Service>> fetchServicesByMerchant(
  String merchantId,
  String token,
) async {
  try {
    final url = Uri.parse(
      'http://api.touchmeapp.com/api/services/merchant/$merchantId',
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

// New function to fetch services by merchant and filter by category
// Replace your fetchServicesByMerchantAndCategory function with this:
Future<List<Service>> fetchServicesByMerchantAndCategory(
  String merchantId,
  String serviceName,
  String token,
) async {
  try {
    final allMerchantServices = await fetchServicesByMerchant(merchantId, token);
    
    // Add debug logging
    print('🔍 Filtering services for merchant: $merchantId');
    print('🔍 Looking for category: "$serviceName"');
    print('🔍 Total services found: ${allMerchantServices.length}');
    
    for (final service in allMerchantServices) {
      print('🔍 Service: "${service.serviceName}"');
    }
    
    // ONLY exact match - service name must equal category name
    final filteredServices = allMerchantServices.where((service) {
      final serviceNameTrimmed = service.serviceName.trim();
      final categoryNameTrimmed = serviceName.trim();
      
      final exactMatch = serviceNameTrimmed == categoryNameTrimmed;
      
      print('🔍 Comparing "${service.serviceName}" with "$serviceName"');
      print('   - Exact match: $exactMatch');
      
      return exactMatch;
    }).toList();

    print('ℹ️ Filtered ${filteredServices.length} services for merchant $merchantId and category: $serviceName');
    
    // Log the filtered results
    for (final service in filteredServices) {
      print('✅ Matched service: "${service.serviceName}"');
    }
    
    return filteredServices;
  } catch (e) {
    print('❌ Error fetching services by merchant and category: $e');
    return [];
  }
}

Future<http.Response> addServiceForMerchant({
  required String merchantId,
  required String token,
  required Service service,
}) async {
  final url = Uri.parse('http://api.touchmeapp.com/api/services/$merchantId');

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