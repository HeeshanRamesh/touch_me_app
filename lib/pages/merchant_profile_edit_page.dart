import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/pages/merchant_login_page.dart';
import 'package:touch_me/services/merchant_auth_service.dart';

class MerchantProfileEditPage extends StatefulWidget {
  const MerchantProfileEditPage({super.key});

  @override
  _MerchantProfileEditPageState createState() => _MerchantProfileEditPageState();
}

class _MerchantProfileEditPageState extends State<MerchantProfileEditPage> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _ownerNameError;
  String? _ownerPhoneError;
  String? _outletNameError;
  String? _outletPhoneError;
  
  // Store current merchant data to preserve existing fields
  Map<String, dynamic>? _currentMerchantData;

  // Owner Information Controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();

  // Outlet Information Controllers
  final TextEditingController _outletNameController = TextEditingController();
  final TextEditingController _outletEmailController = TextEditingController();
  final TextEditingController _outletPhoneController = TextEditingController();
  final TextEditingController _outletAddressController = TextEditingController();

  // Manager Information Controllers
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerEmailController = TextEditingController();
  final TextEditingController _managerPhoneController = TextEditingController();

  // Bank Details Controllers
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankPhoneController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();

  // Focus Nodes
  final _ownerNameFocus = FocusNode();
  final _ownerPhoneFocus = FocusNode();
  final _outletNameFocus = FocusNode();
  final _outletPhoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _ownerNameController.addListener(_validateOwnerName);
    _ownerPhoneController.addListener(_validateOwnerPhone);
    _outletNameController.addListener(_validateOutletName);
    _outletPhoneController.addListener(_validateOutletPhone);
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

      if (response['success'] && response['merchant'] != null) {
        final merchant = response['merchant'];
        
        // Store the complete merchant data for later use
        _currentMerchantData = Map<String, dynamic>.from(merchant);
        
        setState(() {
          // Owner Information
          _ownerNameController.text = merchant['owner']?['name'] ?? '';
          _ownerEmailController.text = merchant['owner']?['email'] ?? '';
          _ownerPhoneController.text = merchant['owner']?['phone'] ?? '';

          // Outlet Information
          _outletNameController.text = merchant['outlet']?['name'] ?? '';
          _outletEmailController.text = merchant['outlet']?['email'] ?? '';
          _outletPhoneController.text = merchant['outlet']?['phone'] ?? '';
          _outletAddressController.text = merchant['outlet']?['address'] ?? '';

          // Manager Information
          _managerNameController.text = merchant['manager']?['name'] ?? '';
          _managerEmailController.text = merchant['manager']?['email'] ?? '';
          _managerPhoneController.text = merchant['manager']?['phone'] ?? '';

          // Bank Details
          _beneficiaryNameController.text = merchant['bankDetails']?['beneficiaryName'] ?? '';
          _accountNumberController.text = merchant['bankDetails']?['accountNumber'] ?? '';
          _bankPhoneController.text = merchant['bankDetails']?['phone'] ?? '';
          _bankNameController.text = merchant['bankDetails']?['bankName'] ?? '';
          _bankBranchController.text = merchant['bankDetails']?['bankBranch'] ?? '';

          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to load profile');
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

  void _validateOwnerName() {
    final name = _ownerNameController.text.trim();
    setState(() {
      _ownerNameError = name.isEmpty ? 'Owner name is required' : null;
    });
  }

  void _validateOwnerPhone() {
    final phone = _ownerPhoneController.text.trim();
    setState(() {
      if (phone.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone)) {
        _ownerPhoneError = 'Enter a valid phone number';
      } else {
        _ownerPhoneError = null;
      }
    });
  }

  void _validateOutletName() {
    final name = _outletNameController.text.trim();
    setState(() {
      _outletNameError = name.isEmpty ? 'Outlet name is required' : null;
    });
  }

  void _validateOutletPhone() {
    final phone = _outletPhoneController.text.trim();
    setState(() {
      if (phone.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone)) {
        _outletPhoneError = 'Enter a valid phone number';
      } else {
        _outletPhoneError = null;
      }
    });
  }

  bool _hasValidationErrors() {
    return _ownerNameError != null || 
           _ownerPhoneError != null || 
           _outletNameError != null || 
           _outletPhoneError != null ||
           _ownerEmailController.text.trim().isEmpty;
  }

  Future<void> _updateProfile() async {
    // Run all validations
    _validateOwnerName();
    _validateOwnerPhone();
    _validateOutletName();
    _validateOutletPhone();

    // Check for validation errors
    if (_hasValidationErrors()) {
      _showErrorSnackBar('Please fill all required fields correctly');
      return;
    }

    // Check if we have current merchant data
    if (_currentMerchantData == null) {
      _showErrorSnackBar('Profile data not loaded. Please refresh and try again.');
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

      // Create updated data by merging with existing data to preserve all fields
      final updatedData = Map<String, dynamic>.from(_currentMerchantData!);
      
      // Update owner information (preserve existing fields like password, role, etc.)
      updatedData['owner'] = {
        ...(_currentMerchantData!['owner'] ?? {}),
        'name': _ownerNameController.text.trim(),
        'phone': _ownerPhoneController.text.trim(),
        // Note: email is disabled in UI, so we don't update it
      };

      // Update outlet information
      updatedData['outlet'] = {
        ...(_currentMerchantData!['outlet'] ?? {}),
        'name': _outletNameController.text.trim(),
        'email': _outletEmailController.text.trim(),
        'phone': _outletPhoneController.text.trim(),
        'address': _outletAddressController.text.trim(),
      };

      // Update manager information
      updatedData['manager'] = {
        ...(_currentMerchantData!['manager'] ?? {}),
        'name': _managerNameController.text.trim(),
        'email': _managerEmailController.text.trim(),
        'phone': _managerPhoneController.text.trim(),
      };

      // Update bank details
      updatedData['bankDetails'] = {
        ...(_currentMerchantData!['bankDetails'] ?? {}),
        'beneficiaryName': _beneficiaryNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'phone': _bankPhoneController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'bankBranch': _bankBranchController.text.trim(),
      };

      // Update timestamps
      final now = DateTime.now().toIso8601String();
      updatedData['updated_date'] = now;
      updatedData['updatedAt'] = now;

      // Send update request
      final response = await MerchantAuthService().updateMerchantProfile(merchantId, updatedData);

      if (!mounted) return;

      if (response['success']) {
        // Update our local copy of the data
        _currentMerchantData = updatedData;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
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

  Future<void> _refreshProfile() async {
    await _loadProfile();
  }

  Future<void> _logout() async {
    try {
      await _storage.delete(key: "token");
      await _storage.delete(key: "merchantId");
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MerchantLoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error logging out: ${e.toString()}');
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A1B9A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? errorText,
    bool enabled = true,
    FocusNode? focusNode,
    VoidCallback? onSubmitted,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          errorText: errorText,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Merchant Profile Edit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Owner Information Section
                    _buildSectionTitle('Owner Information'),
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Name',
                      errorText: _ownerNameError,
                      focusNode: _ownerNameFocus,
                      required: true,
                      onSubmitted: () {
                        if (_ownerNameError == null) {
                          _ownerPhoneFocus.requestFocus();
                        }
                      },
                    ),
                    _buildTextField(
                      controller: _ownerEmailController,
                      label: 'Owner Email',
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: _ownerPhoneController,
                      label: 'Owner Phone',
                      errorText: _ownerPhoneError,
                      focusNode: _ownerPhoneFocus,
                      keyboardType: TextInputType.phone,
                    ),

                    // Outlet Information Section
                    _buildSectionTitle('Outlet Information'),
                    _buildTextField(
                      controller: _outletNameController,
                      label: 'Outlet Name',
                      errorText: _outletNameError,
                      focusNode: _outletNameFocus,
                      required: true,
                      onSubmitted: () {
                        if (_outletNameError == null) {
                          _outletPhoneFocus.requestFocus();
                        }
                      },
                    ),
                    _buildTextField(
                      controller: _outletEmailController,
                      label: 'Outlet Email',
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: _outletPhoneController,
                      label: 'Outlet Phone',
                      errorText: _outletPhoneError,
                      focusNode: _outletPhoneFocus,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _outletAddressController,
                      label: 'Outlet Address',
                    ),

                    // Bank Details Section
                    _buildSectionTitle('Bank Details'),
                    _buildTextField(
                      controller: _beneficiaryNameController,
                      label: 'Beneficiary Name',
                    ),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: 'Account Number',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _bankNameController,
                      label: 'Bank Name',
                    ),
                    _buildTextField(
                      controller: _bankBranchController,
                      label: 'Bank Branch',
                    ),

                    const SizedBox(height: 20),

                    // Update Profile Button
                    ElevatedButton(
                      onPressed: (_isLoading || _hasValidationErrors()) ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Updating...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Update Profile',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Owner Controllers
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    
    // Outlet Controllers
    _outletNameController.dispose();
    _outletEmailController.dispose();
    _outletPhoneController.dispose();
    _outletAddressController.dispose();
    
    // Manager Controllers
    _managerNameController.dispose();
    _managerEmailController.dispose();
    _managerPhoneController.dispose();
    
    // Bank Controllers
    _beneficiaryNameController.dispose();
    _accountNumberController.dispose();
    _bankPhoneController.dispose();
    _bankNameController.dispose();
    _bankBranchController.dispose();
    
    // Focus Nodes
    _ownerNameFocus.dispose();
    _ownerPhoneFocus.dispose();
    _outletNameFocus.dispose();
    _outletPhoneFocus.dispose();
    
    super.dispose();
  }
}