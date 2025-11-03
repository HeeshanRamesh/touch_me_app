import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:touch_me/pages/customer_home_content.dart';
import 'package:touch_me/pages/customer_home_scaffold.dart';
import 'package:touch_me/pages/forgot_password_page.dart';
import 'package:touch_me/pages/signup_page.dart';
import 'package:touch_me/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false; // Add this for Google button loading state
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  final AuthService _authService = AuthService();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _usernameController.text = args['email'] ?? '';
          _passwordController.text = args['password'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome, ${args['email']}! Please login to continue.',
            ),
            backgroundColor: Colors.blue.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });
    _usernameController.addListener(_validateUsername);
    _passwordController.addListener(_validatePassword);
  }

  void _validateUsername() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Email is required';
      });
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(username)) {
      setState(() {
        _usernameError = 'Enter a valid email address';
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

  void _handleFocusChange() {
    if (_usernameFocus.hasFocus) {
      _validateUsername();
      if (_usernameError != null) {
        _usernameFocus.requestFocus();
      }
    } else if (_passwordFocus.hasFocus) {
      _validateUsername();
      if (_usernameError != null) {
        _usernameFocus.requestFocus();
      } else {
        _validatePassword();
        if (_passwordError != null) {
          _passwordFocus.requestFocus();
        }
      }
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
      final response = await _authService.login(username, password);

      if (!mounted) return;
      print('=== LOGIN RESPONSE DEBUG ===');
      print('Success: ${response['success']}');
      print('Token: ${response['token']}');
      print('User data: ${response['user']}');
      print('User type: ${response['user'].runtimeType}');
      if (response['user'] != null) {
        print('User keys: ${response['user'].keys.toList()}');
      }
      print('=== END DEBUG ===');

      if (response['success']) {
        await _handleSuccessfulLogin(response);
      } else {
        _showErrorSnackBar(
          response['message'] ?? 'Authentication failed. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Network error. Please check your connection.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // New Google Sign-In method
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final response = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (response['success']) {
        // Show appropriate message based on whether it's a new user
        final message = response['isNewUser'] == true
            ? 'Account created successfully! Welcome to TouchMe!'
            : 'Login successful! Welcome back!';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        await _handleSuccessfulLogin(response);
      } else {
        _showErrorSnackBar(
          response['message'] ?? 'Google Sign-In failed. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('An error occurred during Google Sign-In.');
    }

    setState(() {
      _isGoogleLoading = false;
    });
  }

  // Extracted common login success handler
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> response) async {
    final userId = response['user']?['id']?.toString() ?? '';
    final firstName = response['user']?['first_name']?.toString() ?? '';
    final lastName = response['user']?['last_name']?.toString() ?? '';
    final userName = '$firstName $lastName';

    await _storage.write(key: 'auth_token', value: response['token']);
    await _storage.write(key: 'user_id', value: userId);
    await _storage.write(key: 'user_name', value: userName);
    await _storage.write(key: 'user_role', value: 'customer');
    await _storage.write(key: 'user_data', value: json.encode(response['user'] ?? {}));

    debugPrint('User ID stored securely: $userId');
    debugPrint('User Name stored securely: $userName');

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerHomeScaffold(
          token: response['token'],
          customerId: response['user']?['id'] ?? '',
          user: response['user'] ?? {},
        ),
      ),
    );
  }

  // Extracted error snackbar method
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Image.asset('assets/app_icon.png', height: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  hintText: 'Email',
                  errorText: _usernameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.grey),
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
                keyboardType: TextInputType.emailAddress,
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
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                    borderSide: const BorderSide(color: Colors.grey),
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
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
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
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or Continue',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _isGoogleLoading ? null : _signInWithGoogle, // Updated
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: _isGoogleLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.red,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
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
                  const Text(
                    'Create An Account ',
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.bold,
                      ),
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