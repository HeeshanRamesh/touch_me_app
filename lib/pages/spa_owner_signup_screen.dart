import 'package:flutter/material.dart';
import 'package:touch_me/pages/spa_owner_login_screen.dart';


class SpaSignupScreen extends StatefulWidget {
  const SpaSignupScreen({super.key});

  @override
  State<SpaSignupScreen> createState() => _SpaSignupScreenState();
}

class _SpaSignupScreenState extends State<SpaSignupScreen> {
  final TextEditingController _spaNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _signup() async {
    final spaName = _spaNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (spaName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Please fill all fields";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = "Password must be at least 6 characters";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup successful! Please log in.")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SpaOwnerLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(height * 0.03),
          child: Column(
            children: [
              Image.asset('assets/app_icon.png', height: height * 0.1),
              const SizedBox(height: 20),
              Text(
                'Create Spa Account',
                style: TextStyle(
                  fontSize: height * 0.03,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 30),

              // Spa Name
              TextField(
                controller: _spaNameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.store),
                  hintText: 'Spa Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  minimumSize: Size(double.infinity, height * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                        : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: height * 0.022,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SpaOwnerLoginPage()),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
