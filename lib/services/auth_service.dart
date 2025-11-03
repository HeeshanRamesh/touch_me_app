// Importing necessary libraries for HTTP requests and JSON handling
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

// AuthService class to handle authentication-related operations
class AuthService {
  static const String baseUrl = 'http://api.touchmeapp.com/api/users';
  static const String authUrl = 'http://api.touchmeapp.com/api/auth';

  // Initialize Google Sign-In for version 6.x
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

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
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/login'),
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
          'user': data['user'],
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

  // NEW: Google Sign-In method for version 6.x
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return {'success': false, 'message': 'Google Sign-In was cancelled'};
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'Failed to get Google ID token'};
      }

      print('Google ID Token obtained: ${idToken.substring(0, 20)}...');

      // Send the ID token to your backend
      final response = await http.post(
        Uri.parse('$authUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': idToken}),
      );

      print('Google auth response status: ${response.statusCode}');
      print('Google auth response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'role': data['role'],
          'isNewUser': data['isNewUser'] ?? false,
          'message':
              data['isNewUser'] == true
                  ? 'Account created successfully!'
                  : 'Login successful!',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message':
                errorData['error']?['message'] ??
                'Google authentication failed',
          };
        } catch (_) {
          return {'success': false, 'message': 'Google authentication failed'};
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return {
        'success': false,
        'message': 'An error occurred during Google Sign-In: ${e.toString()}',
      };
    }
  }

  // NEW: Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('Signed out from Google');
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  // Method to handle forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Forgot Password Response status: ${response.statusCode}');
      print('Forgot Password Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset OTP sent to your email',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Email not found in our records',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to send reset link. Please try again.',
          };
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to verify OTP - NOW RETURNS TOKEN
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      print('Verify OTP Response status: ${response.statusCode}');
      print('Verify OTP Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          'Token from verifyOTP: ${data['tempToken']}',
        ); // Debug log - changed to tempToken
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
          'token':
              data['tempToken'] ??
              '', // Backend returns 'tempToken', not 'token'
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Invalid or expired OTP',
            'token': '',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Invalid or expired OTP',
            'token': '',
          };
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to reset password - Token goes in BODY, not header
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
    String token, // This is the tempToken from verifyOTP
  ) async {
    try {
      print('Attempting to reset password with token: $token'); // Debug log

      final response = await http.post(
        Uri.parse('$authUrl/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          // NO Authorization header - backend expects tempToken in body
        },
        body: json.encode({
          'tempToken': token, // Backend expects 'tempToken' in body
          'newPassword': newPassword,
          // email and otp are NOT needed - token contains email
        }),
      );

      print('Reset Password Response status: ${response.statusCode}');
      print('Reset Password Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully',
        };
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to reset password',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to reset password. Please try again.',
          };
        }
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to get user profile
  Future<Map<String, dynamic>> getUserProfile(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'user': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['error']['message'] ?? 'Failed to load profile',
        };
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Method to update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    String token,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'user': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message':
              errorData['error']['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
