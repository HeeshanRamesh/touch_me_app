import 'package:flutter/material.dart';
import 'package:touch_me/services/auth_service.dart';
import 'login_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _warningMessage;
  final AuthService _authService = AuthService(); // Updated to use AuthService
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Validation methods (no change)
  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(
      r'^[a-z0-9]+(\.[a-z0-9]+)*@gmail\.com$',
    ).hasMatch(value.trim())) {
      return 'Email must use lowercase letters, numbers, or dots and end with @gmail.com';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Sequential input check and other methods are unchanged...
  void _checkSequentialInput(String currentField, BuildContext context) {
    setState(() {
      _warningMessage = null;
    });
    if (currentField == 'lastName' &&
        _validateFirstName(_firstNameController.text) != null) {
      setState(() {
        _warningMessage = 'Please correct the First Name field first';
        _lastNameController.clear();
        _lastNameError = null;
      });
      FocusScope.of(context).requestFocus(_firstNameFocus);
    } else if (currentField == 'email' &&
        (_validateFirstName(_firstNameController.text) != null ||
            _validateLastName(_lastNameController.text) != null)) {
      setState(() {
        _warningMessage =
            'Please correct the First Name and Last Name fields first';
        _emailController.clear();
        _emailError = null;
      });
      if (_validateFirstName(_firstNameController.text) != null) {
        FocusScope.of(context).requestFocus(_firstNameFocus);
      } else {
        FocusScope.of(context).requestFocus(_lastNameFocus);
      }
    } else if (currentField == 'phone' &&
        (_validateFirstName(_firstNameController.text) != null ||
            _validateLastName(_lastNameController.text) != null ||
            _validateEmail(_emailController.text) != null)) {
      setState(() {
        _warningMessage =
            'Please correct the First Name, Last Name, and Email fields first';
        _phoneController.clear();
        _phoneError = null;
      });
      if (_validateFirstName(_firstNameController.text) != null) {
        FocusScope.of(context).requestFocus(_firstNameFocus);
      } else if (_validateLastName(_lastNameController.text) != null) {
        FocusScope.of(context).requestFocus(_lastNameFocus);
      } else {
        FocusScope.of(context).requestFocus(_emailFocus);
      }
    } else if (currentField == 'password' &&
        (_validateFirstName(_firstNameController.text) != null ||
            _validateLastName(_lastNameController.text) != null ||
            _validateEmail(_emailController.text) != null ||
            _validatePhone(_phoneController.text) != null)) {
      setState(() {
        _warningMessage =
            'Please correct the First Name, Last Name, Email, and Phone fields first';
        _passwordController.clear();
        _passwordError = null;
      });
      if (_validateFirstName(_firstNameController.text) != null) {
        FocusScope.of(context).requestFocus(_firstNameFocus);
      } else if (_validateLastName(_lastNameController.text) != null) {
        FocusScope.of(context).requestFocus(_lastNameFocus);
      } else if (_validateEmail(_emailController.text) != null) {
        FocusScope.of(context).requestFocus(_emailFocus);
      } else {
        FocusScope.of(context).requestFocus(_phoneFocus);
      }
    } else if (currentField == 'confirmPassword' &&
        (_validateFirstName(_firstNameController.text) != null ||
            _validateLastName(_lastNameController.text) != null ||
            _validateEmail(_emailController.text) != null ||
            _validatePhone(_phoneController.text) != null ||
            _validatePassword(_passwordController.text) != null)) {
      setState(() {
        _warningMessage =
            'Please correct the First Name, Last Name, Email, Phone, and Password fields first';
        _confirmPasswordController.clear();
        _confirmPasswordError = null;
      });
      if (_validateFirstName(_firstNameController.text) != null) {
        FocusScope.of(context).requestFocus(_firstNameFocus);
      } else if (_validateLastName(_lastNameController.text) != null) {
        FocusScope.of(context).requestFocus(_lastNameFocus);
      } else if (_validateEmail(_emailController.text) != null) {
        FocusScope.of(context).requestFocus(_emailFocus);
      } else if (_validatePhone(_phoneController.text) != null) {
        FocusScope.of(context).requestFocus(_phoneFocus);
      } else {
        FocusScope.of(context).requestFocus(_passwordFocus);
      }
    }
  }

  void _handleFieldSubmission(String currentField, BuildContext context) {
    if (currentField == 'firstName') {
      if (_validateFirstName(_firstNameController.text) == null) {
        FocusScope.of(context).requestFocus(_lastNameFocus);
      }
    } else if (currentField == 'lastName') {
      if (_validateLastName(_lastNameController.text) == null) {
        FocusScope.of(context).requestFocus(_emailFocus);
      }
    } else if (currentField == 'email') {
      if (_validateEmail(_emailController.text) == null) {
        FocusScope.of(context).requestFocus(_phoneFocus);
      }
    } else if (currentField == 'phone') {
      if (_validatePhone(_phoneController.text) == null) {
        FocusScope.of(context).requestFocus(_passwordFocus);
      }
    } else if (currentField == 'password') {
      if (_validatePassword(_passwordController.text) == null) {
        FocusScope.of(context).requestFocus(_confirmPasswordFocus);
      }
    } else if (currentField == 'confirmPassword') {
      if (_validateConfirmPassword(_confirmPasswordController.text) == null) {
        _createAccount();
      }
    }
  }

  Future<void> _createAccount() async {
    setState(() {
      _firstNameError = _validateFirstName(_firstNameController.text);
      _lastNameError = _validateLastName(_lastNameController.text);
      _emailError = _validateEmail(_emailController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
      );
    });

    if (_firstNameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _warningMessage = null;
    });

    final result = await _authService.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    print('Register result: $result');

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Account Created Successfully'),
              content: const Text(
                'Your account has been created. You can now login with your credentials.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Continue'),
                ),
              ],
            ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
          settings: RouteSettings(
            arguments: {
              'email': _emailController.text.trim(),
              'password': _passwordController.text.trim(),
            },
          ),
        ),
      );
    } else {
      setState(() {
        _warningMessage = result['message'];
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
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
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                const SizedBox(height: 20),
                if (_warningMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _warningMessage!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                TextFormField(
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    hintText: 'First Name',
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
                    errorText: _firstNameError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _firstNameError = _validateFirstName(value);
                    });
                    _checkSequentialInput('firstName', context);
                  },
                  onFieldSubmitted:
                      (_) => _handleFieldSubmission('firstName', context),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    hintText: 'Last Name',
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
                    errorText: _lastNameError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _lastNameError = _validateLastName(value);
                    });
                    _checkSequentialInput('lastName', context);
                  },
                  onFieldSubmitted:
                      (_) => _handleFieldSubmission('lastName', context),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    hintText: 'Email',
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
                    errorText: _emailError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _emailError = _validateEmail(value);
                    });
                    _checkSequentialInput('email', context);
                  },
                  onFieldSubmitted:
                      (_) => _handleFieldSubmission('email', context),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                    hintText: 'Phone Number',
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
                    errorText: _phoneError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _phoneError = _validatePhone(value);
                    });
                    _checkSequentialInput('phone', context);
                  },
                  onFieldSubmitted:
                      (_) => _handleFieldSubmission('phone', context),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    hintText: 'Password',
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
                    errorText: _passwordError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _passwordError = _validatePassword(value);
                      _confirmPasswordError = _validateConfirmPassword(
                        _confirmPasswordController.text,
                      );
                    });
                    _checkSequentialInput('password', context);
                  },
                  onFieldSubmitted:
                      (_) => _handleFieldSubmission('password', context),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    hintText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
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
                    errorText: _confirmPasswordError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _confirmPasswordError = _validateConfirmPassword(value);
                    });
                    _checkSequentialInput('confirmPassword', context);
                  },
                  onFieldSubmitted:
                      (_) => _handleFieldSubmission('confirmPassword', context),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Divider(color: Colors.grey.shade400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or Continue',
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement Google sign-in logic
                  },
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
                    Flexible(
                      child: Text(
                        'I Already Have an Account ',
                        style: TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
