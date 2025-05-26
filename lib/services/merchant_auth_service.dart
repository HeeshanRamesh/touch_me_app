import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MerchantAuthService {
  static const String baseUrl = 'http://192.168.8.199:6000/api/merchants/';
  static const String loginUrl = 'http://192.168.8.199:6000/api/users/login';
  static String? _token;

  final storage = const FlutterSecureStorage();

  static String? get token => _token;

  static void setToken(String? newToken) {
    _token = newToken;
  }

  Future<Map<String, dynamic>> signupMerchant({
    required String outletName,
    required String outletEmail,
    required String outletPhone,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
    required String ownerPassword,
    required String managerName,
    required String managerEmail,
    required String managerPhone,
    required String managerPassword,
    required String beneficiaryName,
    required String accountNumber,
    required String bankPhone,
    required String bankName,
    required String bankBranch,
    required String businessRegImage,
    required String logoImage,
    required String nicFrontImage,
    required String nicBackImage,
    required Map<String, Map<String, String>> openingHours,
  }) async {
    final Map<String, dynamic> merchantData = {
      "owner": {
        "name": ownerName,
        "email": ownerEmail,
        "password": ownerPassword,
        "phone": ownerPhone,
      },
      "manager": {
        "name": managerName,
        "email": managerEmail,
        "phone": managerPhone,
        "password": managerPassword,
      },
      "outlet": {
        "name": outletName,
        "email": outletEmail,
        "phone": outletPhone,
        "openingHours": openingHours,
      },
      "businessRegistration": {
        "registrationImage": businessRegImage,
        "logo": logoImage,
        "nic": {
          "frontImage": nicFrontImage,
          "backImage": nicBackImage,
        },
      },
      "bankDetails": {
        "beneficiaryName": beneficiaryName,
        "accountNumber": accountNumber,
        "phone": bankPhone,
        "bankName": bankName,
        "bankBranch": bankBranch,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(merchantData),
      );

      print('Signup Response Status: ${response.statusCode}');
      print('Signup Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final loginResult = await loginMerchant(ownerEmail, ownerPassword);
        if (loginResult['success'] == true) {
          return {
            'success': true,
            'message': 'Merchant registered and logged in successfully',
            'data': responseData,
            'token': _token,
            'role': loginResult['role'],
          };
        } else {
          return {
            'success': true,
            'message': 'Merchant registered successfully, but login failed: ${loginResult['message']}',
            'data': responseData,
          };
        }
      } else {
        return {
          'success': false,
          'message': responseData['error']?['message'] ?? 'Failed to sign up merchant: ${response.statusCode}',
          'error': responseData['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      print('Signup Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> loginMerchant(String email, String password) async {
    try {
      print('Login Payload: ${jsonEncode({'email': email, 'password': password})}');
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Response: Status=${response.statusCode}, Body=${response.body}');

      final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200 && responseData['token'] != null) {
        if (responseData['role'] != 'Merchant') {
          return {
            'success': false,
            'message': 'Account is not a merchant account',
            'token': null,
          };
        }
        setToken(responseData['token']);
        await storage.write(key: "token", value: responseData['token']);
        return {
          'success': true,
          'message': 'Login successful',
          'token': _token,
          'role': responseData['role'] ?? 'Merchant',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid email or password',
          'token': null,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Account is not a merchant account',
          'token': null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed: ${response.statusCode}',
          'token': null,
        };
      }
    } catch (e) {
      print('Login Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'token': null,
      };
    }
  }
}