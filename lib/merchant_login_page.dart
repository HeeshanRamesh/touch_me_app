import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this import
import 'package:touch_me/merchant_forgot_password.dart';
import 'package:touch_me/merchant_page.dart';
import 'package:touch_me/merchant_signup_main.dart';
import 'package:touch_me/saloon_dashboard_screen.dart';
import 'package:touch_me/services/merchant_auth_service.dart';

class MerchantLoginPage extends StatefulWidget {
  final String? username;
  const MerchantLoginPage({super.key, this.username});

  @override
  _MerchantLoginPageState createState() => _MerchantLoginPageState();
}

class _MerchantLoginPageState extends State<MerchantLoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  // Add this line - declare storage
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      _usernameController.text = widget.username!;
    }
    _usernameController.addListener(_validateUsername);
    _passwordController.addListener(_validatePassword);
  }

  void _validateUsername() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Email is required';
      });
    } else if (!RegExp(r'^[a-zA-Z0-9]+@gmail\.com$').hasMatch(username)) {
      setState(() {
        _usernameError = 'Enter a valid Gmail address (e.g., example@gmail.com)';
      });
    } else {
      setState(() {
        _usernameError = null;
      });
    }
  }

  void _validatePassword() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  Future<void> _login() async {
  _validateUsername();
  _validatePassword();

  if (_usernameError != null || _passwordError != null) {
    return;
  }

  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  setState(() {
    _isLoading = true;
  });

  try {
    final response = await MerchantAuthService().loginMerchant(
      username,
      password,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (response['success']) {
      // Debug line
      print("Login full response: $response");

      // Save authentication token - THIS IS THE IMPORTANT PART
      if (response['token'] != null) {
        await storage.write(key: "authToken", value: response['token']);
        print("Auth token saved: ${response['token']}");
      } else if (response['accessToken'] != null) {
        // Some APIs use 'accessToken' instead of 'token'
        await storage.write(key: "authToken", value: response['accessToken']);
        print("Auth token saved: ${response['accessToken']}");
      } else if (response['jwt'] != null) {
        // Some APIs use 'jwt' instead of 'token'
        await storage.write(key: "authToken", value: response['jwt']);
        print("Auth token saved: ${response['jwt']}");
      } else {
        print("Warning: Auth token not found in response");
        print("Available keys: ${response.keys.toList()}");
      }

      // Save merchant ID to storage
      if (response['merchant'] != null && response['merchant']['_id'] != null) {
        await storage.write(key: "merchantId", value: response['merchant']['_id']);
        print("Merchant ID saved: ${response['merchant']['_id']}");
      } else if (response['merchant'] != null && response['merchant']['id'] != null) {
        // Try 'id' instead of '_id'
        await storage.write(key: "merchantId", value: response['merchant']['id']);
        print("Merchant ID saved: ${response['merchant']['id']}");
      } else {
        print("Warning: Merchant ID not found in response");
        print("Merchant object: ${response['merchant']}");
      }

      // Get owner name from response['merchant']['owner']['name']
      String ownerName = "Merchant";
      if (response['merchant'] != null &&
          response['merchant']['owner'] != null &&
          response['merchant']['owner']['name'] != null &&
          response['merchant']['owner']['name'].toString().isNotEmpty) {
        ownerName = response['merchant']['owner']['name'];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful! Redirecting...'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantPage(userName: ownerName),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ??
                'Authentication failed. Please check your credentials or account type.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error: ${e.toString()}'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (widget.username != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome, ${widget.username}! Please login to continue.',
            ),
            backgroundColor: Colors.blue.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Image.asset(
                  'assets/app_icon.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Merchant Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 127, 9, 143),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  hintText: 'Email',
                  errorText: _usernameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                  ),
                ),
                onSubmitted: (_) {
                  if (_usernameError == null) {
                    _passwordFocus.requestFocus();
                  }
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  hintText: 'Password',
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                  ),
                ),
                onSubmitted: (_) {
                  if (_passwordError == null) {
                    _login();
                  }
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MerchantForgetPasswordPage(),
                        ),
                      );
                    }, // TODO: Implement forgot password
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading || _usernameError != null || _passwordError != null
                    ? null
                    : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Or Continue', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {}, // TODO: Implement Google sign-in
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'With Google',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Create An Account ', style: TextStyle(color: Colors.black)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MerchantSignupMain()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Color(0xFF6A1B9A), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}