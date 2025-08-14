import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/services/auth_service.dart';

class ProfilePersonalDetailsScreen extends StatefulWidget {
  const ProfilePersonalDetailsScreen({super.key});

  @override
  _ProfilePersonalDetailsScreenState createState() =>
      _ProfilePersonalDetailsScreenState();
}

class _ProfilePersonalDetailsScreenState
    extends State<ProfilePersonalDetailsScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  String? _userId;
  String? _token;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Get stored user ID and token
      _userId = await _storage.read(key: 'user_id');
      _token = await _storage.read(key: 'auth_token');

      if (_userId != null && _token != null) {
        // Fetch user profile from API
        final response = await _authService.getUserProfile(_userId!, _token!);
        
        if (response['success']) {
          _userData = response['user'];
          _populateFields();
        } else {
          _showError(response['message'] ?? 'Failed to load profile');
        }
      } else {
        _showError('User session expired. Please login again.');
      }
    } catch (e) {
      _showError('Network error. Please check your connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFields() {
    if (_userData != null) {
      // Combine first_name and last_name as username
      final firstName = _userData!['first_name'] ?? '';
      final lastName = _userData!['last_name'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      
      _nameController.text = fullName.isNotEmpty ? fullName : 'N/A';
      _emailController.text = _userData!['email'] ?? 'N/A';
      _phoneController.text = _userData!['phone_number'] ?? 'N/A';
      _roleController.text = _userData!['role'] ?? 'N/A';
      
      // You can set a default location or add it to your backend
     // _locationController.text = _userData!['location'] ?? 'Not specified';
    }
  }

  void _showError(String message) {
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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_userId == null || _token == null) {
      _showError('User session expired. Please login again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Split the full name back to first and last name
      final fullName = _nameController.text.trim();
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

      final profileData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        // Note: role typically shouldn't be editable by users
      };

      final response = await _authService.updateUserProfile(
        _userId!,
        _token!,
        profileData,
      );

      if (response['success']) {
        _userData = response['user'];
        _populateFields();
        
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        _showError(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showError('Network error. Please check your connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E8EE),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: _isEditing && !readOnly
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                )
              : Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.black,
              ),
              onPressed: _isEditing ? () {
                setState(() {
                  _isEditing = false;
                  _populateFields(); // Reset fields
                });
              } : _toggleEditMode,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF6A1B9A),
                            child: Text(
                              _getInitials(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6A1B9A),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement image picker
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Name Field
                    _buildField('Full Name', _nameController),
                    const SizedBox(height: 20),
                    
                    // Email Field
                    _buildField('Email', _emailController),
                    const SizedBox(height: 20),
                    
                    // Phone Field
                    _buildField('Phone Number', _phoneController),
                    const SizedBox(height: 20),
                    
                    // // Location Field
                    // _buildField('Location', _locationController),
                    // const SizedBox(height: 20),
                    
                    // Role Field (Read-only)
                    _buildField('Role', _roleController, readOnly: true),
                    const SizedBox(height: 40),
                    
                    // Save/Edit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _isEditing ? _saveChanges : _toggleEditMode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Edit Profile',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  String _getInitials() {
    if (_userData != null) {
      final firstName = _userData!['first_name'] ?? '';
      final lastName = _userData!['last_name'] ?? '';
      
      String initials = '';
      if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
      if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
      
      return initials.isNotEmpty ? initials : 'U';
    }
    return 'U';
  }
}