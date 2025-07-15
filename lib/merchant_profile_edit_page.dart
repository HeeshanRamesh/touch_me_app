import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:touch_me/merchant_login_page.dart';
import 'package:touch_me/services/merchant_auth_service.dart';

class MerchantProfileEditPage extends StatefulWidget {
  const MerchantProfileEditPage({super.key});

  @override
  State<MerchantProfileEditPage> createState() => _MerchantProfileEditPageState();
}

class _MerchantProfileEditPageState extends State<MerchantProfileEditPage> {
  final _storage = const FlutterSecureStorage();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _memberIdController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _jobTitleFocus = FocusNode();
  final _memberIdFocus = FocusNode();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _firstNameController.addListener(_validateFirstName);
    _lastNameController.addListener(_validateLastName);
    _phoneController.addListener(_validatePhoneNumber);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final merchantId = await _storage.read(key: "merchantId");
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      final response = await MerchantAuthService().getMerchantProfile(merchantId);

      if (!mounted) return;

      if (response['success'] && response['user'] != null) {
        setState(() {
          _firstNameController.text = response['user']['first_name'] ?? '';
          _lastNameController.text = response['user']['last_name'] ?? '';
          _phoneController.text = response['user']['phone_number'] ?? '';
          _emailController.text = response['user']['email'] ?? '';
          _jobTitleController.text = response['user']['job_title'] ?? '';
          _memberIdController.text = response['user']['member_id'] ?? '';
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('Failed to load profile');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error loading profile: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _validateFirstName() {
    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      setState(() {
        _firstNameError = 'First name is required';
      });
    } else {
      setState(() {
        _firstNameError = null;
      });
    }
  }

  void _validateLastName() {
    final lastName = _lastNameController.text.trim();
    if (lastName.isEmpty) {
      setState(() {
        _lastNameError = 'Last name is required';
      });
    } else {
      setState(() {
        _lastNameError = null;
      });
    }
  }

  void _validatePhoneNumber() {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phoneNumber)) {
      setState(() {
        _phoneError = 'Enter a valid phone number';
      });
    } else {
      setState(() {
        _phoneError = null;
      });
    }
  }

  Future<void> _updateProfile() async {
    _validateFirstName();
    _validateLastName();
    _validatePhoneNumber();

    if (_firstNameError != null || _lastNameError != null || _phoneError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final merchantId = await _storage.read(key: "merchantId");
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      final updatedData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'job_title': _jobTitleController.text.trim(),
        'member_id': _memberIdController.text.trim(),
      };

      final response = await MerchantAuthService().updateMerchantProfile(merchantId, updatedData);

      if (!mounted) return;

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Network error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('No image selected'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Edit Merchant Profile'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        errorText: _firstNameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (_firstNameError == null) {
                          _lastNameFocus.requestFocus();
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        errorText: _lastNameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (_lastNameError == null) {
                          _phoneFocus.requestFocus();
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        errorText: _phoneError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onSubmitted: (_) {
                        if (_phoneError == null) {
                          _jobTitleFocus.requestFocus();
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    // const SizedBox(height: 15),
                    // TextField(
                    //   controller: _jobTitleController,
                    //   focusNode: _jobTitleFocus,
                    //   decoration: InputDecoration(
                    //     labelText: 'Job Title',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                    //     ),
                    //   ),
                    //   onSubmitted: (_) {
                    //     _memberIdFocus.requestFocus();
                    //   },
                    // ),
                    // const SizedBox(height: 15),
                    // TextField(
                    //   controller: _memberIdController,
                    //   focusNode: _memberIdFocus,
                    //   decoration: InputDecoration(
                    //     labelText: 'Member ID Number',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: Colors.grey),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //       borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading || _firstNameError != null || _lastNameError != null || _phoneError != null
                          ? null
                          : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
}