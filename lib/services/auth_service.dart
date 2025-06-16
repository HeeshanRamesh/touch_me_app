// Importing necessary libraries for HTTP requests and JSON handling
import 'dart:convert';
import 'package:http/http.dart' as http;

// AuthService class to handle authentication-related operations
class AuthService {
  static const String baseUrl = 'http://api.touchmeapp.com/api/users';

  // Method to register a new user
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'role': 'Customer',
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Account created successfully',
          'data': jsonDecode(response.body),
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Exception occurred: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method to handle user login
  // auth_service.dart
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://api.touchmeapp.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] ?? '';
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'token': token,
          'user': data['user'], // <-- Include the user map!
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Invalid username or password',
            'token': '',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Invalid username or password',
            'token': '',
          };
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
