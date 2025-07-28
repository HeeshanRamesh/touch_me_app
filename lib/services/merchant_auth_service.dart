import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MerchantAuthService {
  static const String baseUrl = 'http://api.touchmeapp.com/api/merchants/';
  static const String loginUrl = 'http://api.touchmeapp.com/api/auth/login';
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
    required String outletPicture,
    required String outletAddress,
    required String ownerName,
    required String ownerEmail,
    required String ownerPhone,
    required String ownerPassword,
    // required String managerName,
    // required String managerEmail,
    // required String managerPhone,
    // required String managerPassword,
    required String beneficiaryName,
    required String accountNumber,
    //required String bankPhone,
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
      // "manager": {
      //   "name": managerName,
      //   "email": managerEmail,
      //   "phone": managerPhone,
      //   "password": managerPassword,
      // },
      "outlet": {
        "name": outletName,
        "email": outletEmail,
        "phone": outletPhone,
        "picture": outletPicture,
        "address": outletAddress,
        "openingHours": openingHours,
      },
      "businessRegistration": {
        "registrationImage": businessRegImage,
        "logo": logoImage,
        "nic": {"frontImage": nicFrontImage, "backImage": nicBackImage},
      },
      "bankDetails": {
        "beneficiaryName": beneficiaryName,
        "accountNumber": accountNumber,
        //"phone": bankPhone,
        "bankName": bankName,
        "bankBranch": bankBranch,
      },
    };


    
    try {
      print('Signup Request Body: ${jsonEncode(merchantData)}');
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
            'message':
                'Merchant registered successfully, but login failed: ${loginResult['message']}',
            'data': responseData,
          };
        }
      } else {
        return {
          'success': false,
          'message':
              responseData['error']?['message'] ??
              'Failed to sign up merchant: ${response.statusCode}',
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

  Future<Map<String, dynamic>> loginMerchant(
    String email,
    String password,
  ) async {
    try {
      print(
        'Login Payload: ${jsonEncode({'email': email, 'password': password})}',
      );
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print(
        'Login Response: Status=${response.statusCode}, Body=${response.body}',
      );

      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

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

        // Save merchant ID to storage
        if (responseData['merchant'] != null &&
            (responseData['merchant']['id'] != null ||
                responseData['merchant']['_id'] != null)) {
          String merchantId =
              responseData['merchant']['id'] ?? responseData['merchant']['_id'];
          await storage.write(key: "merchantId", value: merchantId);
          print("Merchant ID saved: $merchantId");
        }

        return {
          'success': true,
          'message': 'Login successful',
          'token': _token,
          'role': responseData['role'] ?? 'Merchant',
          'merchant':
              responseData['merchant'], // Changed from 'user' to 'merchant'
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
          'message':
              responseData['message'] ?? 'Login failed: ${response.statusCode}',
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

  Future<Map<String, dynamic>> getMerchantProfile(String merchantId) async {
    try {
      final token = await storage.read(
        key: "token",
      ); // Changed from "authToken" to "token"
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl$merchantId'), // Changed from profileUrl to baseUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        'Get Profile Response: Status=${response.statusCode}, Body=${response.body}',
      );

      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile retrieved successfully',
          'merchant': responseData, // Changed from 'user' to 'merchant'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': responseData['error']?['message'] ?? 'Profile not found',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['error']?['message'] ??
              'Failed to retrieve profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Get Profile Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateMerchantProfile(
    String merchantId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final token = await storage.read(
        key: "token",
      ); // Changed from "authToken" to "token"
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl$merchantId'), // Changed from profileUrl to baseUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedData),
      );

      print(
        'Update Profile Response: Status=${response.statusCode}, Body=${response.body}',
      );

      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'merchant': responseData, // Changed from 'user' to 'merchant'
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message':
              responseData['error']?['message'] ?? 'Invalid data provided',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['error']?['message'] ??
              'Failed to update profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Update Profile Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
  // Add this method to your MerchantAuthService class

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    const String forgotPasswordUrl =
        'http://api.touchmeapp.com/api/merchants/forgot-password';
    try {
      print('Forgot Password Request for email: $email');

      final response = await http.post(
        Uri.parse(forgotPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print(
        'Forgot Password Response: Status=${response.statusCode}, Body=${response.body}',
      );

      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ??
              'Password reset email sent successfully',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Email address not found',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Invalid email address',
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Failed to send reset email: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Forgot Password Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
// Add this method to your existing MerchantAuthService class

//   Future<Map<String, dynamic>> resetPassword(
//     String email,
//     String otp,
//     String newPassword,
//   ) async {
//     const String resetPasswordUrl =
//         'http://api.touchmeapp.com:1000/api/merchants/reset-password';

//     try {
//       print('Reset Password Request for email: $email, otp: $otp');

//       final response = await http.post(
//         Uri.parse(resetPasswordUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//           'newPassword': newPassword,
//         }),
//       );

//       print(
//         'Reset Password Response: Status=${response.statusCode}, Body=${response.body}',
//       );

//       final responseData =
//           response.body.isNotEmpty ? jsonDecode(response.body) : {};

//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'message': responseData['message'] ?? 'Password reset successful',
//         };
//       } else if (response.statusCode == 404) {
//         return {
//           'success': false,
//           'message': responseData['message'] ?? 'Merchant not found',
//         };
//       } else if (response.statusCode == 400) {
//         return {
//           'success': false,
//           'message': responseData['message'] ?? 'Invalid or expired OTP',
//         };
//       } else {
//         return {
//           'success': false,
//           'message':
//               responseData['message'] ??
//               'Failed to reset password: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('Reset Password Error: $e');
//       return {'success': false, 'message': 'Network error: ${e.toString()}'};
//     }
//   }
// }
