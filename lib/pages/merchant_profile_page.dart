import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/pages/merchant_login_page.dart';
import 'package:touch_me/services/merchant_auth_service.dart';

class MerchantProfilePage extends StatefulWidget {
  final String userName;
  const MerchantProfilePage({super.key, required this.userName});

  @override
  _MerchantProfilePageState createState() => _MerchantProfilePageState();
}

class _MerchantProfilePageState extends State<MerchantProfilePage> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  String? _ownerNameError;
  String? _ownerPhoneError;
  String? _outletNameError;
  String? _outletPhoneError;

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
  // final TextEditingController _managerNameController = TextEditingController();
  // final TextEditingController _managerEmailController = TextEditingController();
  // final TextEditingController _managerPhoneController = TextEditingController();

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
          // _managerNameController.text = merchant['manager']?['name'] ?? '';
          // _managerEmailController.text = merchant['manager']?['email'] ?? '';
          // _managerPhoneController.text = merchant['manager']?['phone'] ?? '';

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
    if (name.isEmpty) {
      setState(() {
        _ownerNameError = 'Owner name is required';
      });
    } else {
      setState(() {
        _ownerNameError = null;
      });
    }
  }

  void _validateOwnerPhone() {
    final phone = _ownerPhoneController.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone)) {
      setState(() {
        _ownerPhoneError = 'Enter a valid phone number';
      });
    } else {
      setState(() {
        _ownerPhoneError = null;
      });
    }
  }

  void _validateOutletName() {
    final name = _outletNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _outletNameError = 'Outlet name is required';
      });
    } else {
      setState(() {
        _outletNameError = null;
      });
    }
  }

  void _validateOutletPhone() {
    final phone = _outletPhoneController.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone)) {
      setState(() {
        _outletPhoneError = 'Enter a valid phone number';
      });
    } else {
      setState(() {
        _outletPhoneError = null;
      });
    }
  }

  Future<void> _updateProfile() async {
    _validateOwnerName();
    _validateOwnerPhone();
    _validateOutletName();
    _validateOutletPhone();

    if (_ownerNameError != null || _ownerPhoneError != null || 
        _outletNameError != null || _outletPhoneError != null) {
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
        'owner': {
          'name': _ownerNameController.text.trim(),
          'phone': _ownerPhoneController.text.trim(),
        },
        'outlet': {
          'name': _outletNameController.text.trim(),
          'phone': _outletPhoneController.text.trim(),
          'address': _outletAddressController.text.trim(),
        },
        // 'manager': {
        //   'name': _managerNameController.text.trim(),
        //   'email': _managerEmailController.text.trim(),
        //   'phone': _managerPhoneController.text.trim(),
        // },
        'bankDetails': {
          'beneficiaryName': _beneficiaryNameController.text.trim(),
          'accountNumber': _accountNumberController.text.trim(),
          'phone': _bankPhoneController.text.trim(),
          'bankName': _bankNameController.text.trim(),
          'bankBranch': _bankBranchController.text.trim(),
        },
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
      } else {
        _showErrorSnackBar(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error updating profile: ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Profile'),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Owner Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _ownerNameController,
                    label: 'Owner Name',
                    errorText: _ownerNameError,
                  ),
                  _buildTextField(
                    controller: _ownerEmailController,
                    label: 'Owner Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _ownerPhoneController,
                    label: 'Owner Phone',
                    keyboardType: TextInputType.phone,
                    errorText: _ownerPhoneError,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Outlet Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _outletNameController,
                    label: 'Outlet Name',
                    errorText: _outletNameError,
                  ),
                  _buildTextField(
                    controller: _outletEmailController,
                    label: 'Outlet Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _outletPhoneController,
                    label: 'Outlet Phone',
                    keyboardType: TextInputType.phone,
                    errorText: _outletPhoneError,
                  ),
                  _buildTextField(
                    controller: _outletAddressController,
                    label: 'Outlet Address',
                  ),
                  // const SizedBox(height: 20),
                  // const Text(
                  //   'Manager Information',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // const SizedBox(height: 10),
                  // _buildTextField(
                  //   controller: _managerNameController,
                  //   label: 'Manager Name',
                  // ),
                  // _buildTextField(
                  //   controller: _managerEmailController,
                  //   label: 'Manager Email',
                  //   keyboardType: TextInputType.emailAddress,
                  // ),
                  // _buildTextField(
                  //   controller: _managerPhoneController,
                  //   label: 'Manager Phone',
                  //   keyboardType: TextInputType.phone,
                  // ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bank Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
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
                    controller: _bankPhoneController,
                    label: 'Bank Phone',
                    keyboardType: TextInputType.phone,
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
                  OutlinedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Color(0xFF6A1B9A)),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF6A1B9A),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you want Logout from touch Me app!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Added: Clear all secure storage
                        final _storage = const FlutterSecureStorage();
                        await _storage.deleteAll();
                        // Perform logout action
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MerchantLoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog and stay on ProfileScreen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'NO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    // _managerNameController.dispose();
    // _managerEmailController.dispose();
    // _managerPhoneController.dispose();
    
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