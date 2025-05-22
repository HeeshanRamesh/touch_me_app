import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_me/login_page.dart';

// Service model to map the API response
class Service {
  final String id;
  final String serviceName;
  final String serviceDescription;
  final double price;
  final String image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.serviceName,
    required this.serviceDescription,
    required this.price,
    required this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceDescription: json['serviceDescription'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }
}

class ServiceApi {
  static const String _baseUrl = 'http://192.168.8.111:6000/api/services';

  Future<List<Service>> fetchServices(String authToken, BuildContext context) async {
    const retryOptions = RetryOptions(
      maxAttempts: 3,
      delayFactor: Duration(seconds: 1),
    );

    try {
      print('Attempting to fetch services from $_baseUrl with token: $authToken');
      final response = await retry(
        () async => await http.get(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is http.ClientException || e is TimeoutException,
        onRetry: (e) => print('Retrying GET due to: $e'),
      );

      print('Received response with status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed ${data.length} services from API response');
        return data.map((json) => Service.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('Unauthorized: Logging out user due to invalid token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Failed to load services: HTTP ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching services: $e');
      throw Exception('Error fetching services: $e');
    }
  }
}