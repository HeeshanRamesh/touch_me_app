import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchantChangePasswordPage extends StatefulWidget {
  final String? merchantId; // Nullable to handle cases where ID is not passed
  const MerchantChangePasswordPage({Key? key, this.merchantId})
    : super(key: key);

  @override
  State<MerchantChangePasswordPage> createState() =>
      _MerchantChangePasswordPageState();
}

class _MerchantChangePasswordPageState extends State<MerchantChangePasswordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  // Password requirements
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  double _passwordStrength = 0.0;
  String _strengthText = 'Enter a password';
  Color _strengthColor = Colors.grey;

  late AnimationController _strengthAnimationController;
  late Animation<double> _strengthAnimation;
  String? _merchantId; // Store the resolved merchantId
  String? _authToken; // Store the authentication token

  final storage =
      const FlutterSecureStorage(); // ✅ Use FlutterSecureStorage instead of SharedPreferences

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _strengthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _strengthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _strengthAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add listeners for password validation
    _newPasswordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateForm);
    _currentPasswordController.addListener(_validateForm);

    // Resolve merchantId and authToken
    _resolveCredentials();
  }

  Future<void> _resolveCredentials() async {
    if (widget.merchantId != null && widget.merchantId!.isNotEmpty) {
      _merchantId = widget.merchantId;
      print('Merchant ID (from widget): $_merchantId');
    } else {
      _merchantId = await storage.read(
        key: 'merchantId',
      ); // ✅ Use FlutterSecureStorage
      print('Merchant ID (from FlutterSecureStorage): $_merchantId');
    }
    _authToken = await storage.read(
      key: 'authToken',
    ); // ✅ Use FlutterSecureStorage
    print('Auth Token (from FlutterSecureStorage): $_authToken');
    setState(() {}); // Update UI after resolving credentials
  }

  @override
  void dispose() {
    _strengthAnimationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[^A-Za-z0-9]'));

      int validCount = 0;
      if (_hasMinLength) validCount++;
      if (_hasUppercase) validCount++;
      if (_hasLowercase) validCount++;
      if (_hasNumber) validCount++;
      if (_hasSpecialChar) validCount++;

      _passwordStrength = validCount / 5.0;

      if (validCount == 0) {
        _strengthText = 'Enter a password';
        _strengthColor = Colors.grey;
      } else if (validCount < 3) {
        _strengthText = 'Weak';
        _strengthColor = Colors.red;
      } else if (validCount < 5) {
        _strengthText = 'Good';
        _strengthColor = Colors.orange;
      } else {
        _strengthText = 'Strong';
        _strengthColor = Colors.green;
      }
    });

    _strengthAnimationController.animateTo(_passwordStrength);
    _validateForm();
  }

  void _validateForm() {
    setState(() {});
  }

  bool get _isFormValid {
    return _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar &&
        _newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text != _currentPasswordController.text;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) return;

    // Validate merchantId
    if (_merchantId == null || _merchantId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid merchant ID. Please try logging in again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Validate authToken
    if (_authToken == null || _authToken!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token missing. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use localhost endpoint for testing; switch to production endpoint as needed
      final String apiUrl =
          'http://api.touchmeapp.com/api/merchants/$_merchantId/change-password';

      // Prepare the request payload
      final Map<String, String> payload = {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      };

      // Log the request details for debugging
      print('API URL: $apiUrl');
      print('Payload: $payload');
      print('Auth Token: $_authToken');

      // Make the API call
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_authToken',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      // Log the response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Handle the response
      if (response.statusCode == 200) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset form
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _validatePassword();

          // Navigate back to previous page after successful password change
          Navigator.of(context).pop();
        }
      } else {
        // Handle error response
        String errorMessage = 'Failed to change password';
        if (response.statusCode == 404) {
          errorMessage =
              'API endpoint not found. Please check the server configuration.';
        } else {
          try {
            final responseBody = jsonDecode(response.body);
            errorMessage = responseBody['message'] ?? errorMessage;
          } catch (e) {
            print('Error parsing response body: $e');
            if (response.statusCode == 401) {
              errorMessage = 'Unauthorized. Please log in again.';
            } else if (response.statusCode == 400) {
              errorMessage = 'Invalid request. Please check your input.';
            }
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      // Log the exception for debugging
      print('Exception occurred: $e');

      // Handle specific types of errors
      String errorMessage = 'An error occurred. Please try again.';
      if (e is http.ClientException) {
        errorMessage = 'Network error: Unable to connect to the server.';
      } else if (e is TimeoutException) {
        errorMessage = 'Request timed out. Please check your connection.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 2),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (suffixWidget != null) suffixWidget,
                IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem({required bool isValid, required String text}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isValid ? Colors.green : Colors.transparent,
            border: Border.all(
              color: isValid ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
          child:
              isValid
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isValid ? Colors.green : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if merchantId is valid
    if (_merchantId == null || _merchantId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error: Invalid Merchant ID',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please log in again to retrieve your merchant ID.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed('/login'); // Adjust route as needed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                padding: const EdgeInsets.all(40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'Change Password',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Create a strong, secure password for your account',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Current Password
                      _buildPasswordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        obscureText: !_showCurrentPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showCurrentPassword = !_showCurrentPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // New Password
                      _buildPasswordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        obscureText: !_showNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey[300]!,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Password Requirements:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirementItem(
                              isValid: _hasMinLength,
                              text: 'At least 8 characters',
                            ),
                            const SizedBox(height: 5),
                            _buildRequirementItem(
                              isValid: _hasUppercase,
                              text: 'One uppercase letter',
                            ),
                            const SizedBox(height: 5),
                            _buildRequirementItem(
                              isValid: _hasLowercase,
                              text: 'One lowercase letter',
                            ),
                            const SizedBox(height: 5),
                            _buildRequirementItem(
                              isValid: _hasNumber,
                              text: 'One number',
                            ),
                            const SizedBox(height: 5),
                            _buildRequirementItem(
                              isValid: _hasSpecialChar,
                              text: 'One special character',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Strength Meter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: AnimatedBuilder(
                              animation: _strengthAnimation,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _strengthAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _strengthColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _strengthText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Confirm Password
                      _buildPasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        suffixWidget:
                            _confirmPasswordController.text.isNotEmpty &&
                                    _newPasswordController.text ==
                                        _confirmPasswordController.text
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                )
                                : null,
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isFormValid && !_isLoading
                                  ? _changePassword
                                  : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _isFormValid ? 5 : 0,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
