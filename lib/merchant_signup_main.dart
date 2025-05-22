import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:touch_me/saloon_dashboard_screen.dart';
import 'package:intl/intl.dart';
import 'package:touch_me/services/merchant_auth_service.dart';
import 'package:touch_me/merchant_login_page.dart';

class MerchantSignupMain extends StatefulWidget {
  const MerchantSignupMain({super.key});

  @override
  State<MerchantSignupMain> createState() => _MerchantSignupMainState();
}

class _MerchantSignupMainState extends State<MerchantSignupMain> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // Form controllers
  final TextEditingController _outletNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPasswordController = TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerEmailController = TextEditingController();
  final TextEditingController _managerPasswordController = TextEditingController();
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  // Form keys for validation
  final GlobalKey<FormState> _outletInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bankInfoFormKey = GlobalKey<FormState>();

  // State for uploads and selections
  String? _phoneNumber;
  String? _managerPhoneNumber;
  String? _bankPhoneNumber;
  bool _taxRegistered = false;
  bool _nicFrontUploaded = false;
  bool _nicBackUploaded = false;
  bool _businessRegUploaded = false;
  bool _logoUploaded = false;
  bool _bankStatementUploaded = false;
  String? _selectedBank;
  String? _selectedBranch;

  // Simulated URLs for uploaded files (replace with actual file upload logic)
  String? _businessRegImageUrl;
  String? _logoImageUrl;
  String? _nicFrontImageUrl;
  String? _nicBackImageUrl;
  String? _bankStatementImageUrl;

  // Opening hours (hardcoded for now, as per API example)
  Map<String, Map<String, String>> _openingHours = {
    "monday": {"open": "08:00", "close": "18:00"},
    "tuesday": {"open": "08:00", "close": "18:00"},
    "wednesday": {"open": "08:00", "close": "18:00"},
    "thursday": {"open": "08:00", "close": "18:00"},
    "friday": {"open": "08:00", "close": "18:00"},
    "saturday": {"open": "09:00", "close": "15:00"},
    "sunday": {"open": "", "close": ""},
  };

  @override
  void dispose() {
    _outletNameController.dispose();
    _emailController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    _managerNameController.dispose();
    _managerEmailController.dispose();
    _managerPasswordController.dispose();
    _beneficiaryNameController.dispose();
    _accountNumberController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void next() {
    bool isValid = true;
    switch (_page) {
      case 0:
        isValid = _outletInfoFormKey.currentState?.validate() ?? false;
        if (isValid && _phoneNumber == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter a valid phone number"),
              backgroundColor: Colors.red,
            ),
          );
          isValid = false;
        }
        break;
      case 1:
        isValid = _contactInfoFormKey.currentState?.validate() ?? false;
        if (isValid && _managerPhoneNumber == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter a valid manager phone number"),
              backgroundColor: Colors.red,
            ),
          );
          isValid = false;
        }
        break;
      case 2:
        isValid = _validateBusinessInfoStep();
        break;
      case 3:
        isValid = _bankInfoFormKey.currentState?.validate() ?? false;
        if (isValid) isValid = _validateBankInfoStep();
        if (isValid && _bankPhoneNumber == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter a valid bank phone number"),
              backgroundColor: Colors.red,
            ),
          );
          isValid = false;
        }
        break;
    }

    if (!isValid) return;

    if (_page < 3) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isSubmitting = false);
        _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getSuccessMessageForPage(_page)),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  bool _validateBusinessInfoStep() {
    if (!_businessRegUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload business registration"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (!_nicFrontUploaded || !_nicBackUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload both sides of your NIC"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (!_logoUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your outlet logo"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateBankInfoStep() {
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your bank"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your bank branch"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (!_bankStatementUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your bank statement"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  String _getSuccessMessageForPage(int page) {
    switch (page) {
      case 0:
        return "Outlet information saved successfully!";
      case 1:
        return "Contact details saved successfully!";
      case 2:
        return "Business information saved successfully!";
      default:
        return "Step completed successfully!";
    }
  }

  void back() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String _simulateFileUpload(String fileType) {
    return "http://example.com/$fileType.jpg";
  }

  Future<void> _submitForm() async {
    if (!_bankInfoFormKey.currentState!.validate()) return;
    if (!_validateBankInfoStep()) return;
    if (_phoneNumber == null || _managerPhoneNumber == null || _bankPhoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please ensure all phone numbers are provided"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_businessRegImageUrl == null ||
        _logoImageUrl == null ||
        _nicFrontImageUrl == null ||
        _nicBackImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please ensure all required images are uploaded"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await MerchantAuthService().signupMerchant(
        outletName: _outletNameController.text.trim(),
        outletEmail: _emailController.text.trim(),
        outletPhone: _phoneNumber!,
        ownerName: _ownerNameController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        ownerPhone: _phoneNumber!, // Using outlet phone for simplicity
        ownerPassword: _ownerPasswordController.text.trim(),
        managerName: _managerNameController.text.trim(),
        managerEmail: _managerEmailController.text.trim(),
        managerPhone: _managerPhoneNumber!,
        managerPassword: _managerPasswordController.text.trim(),
        beneficiaryName: _beneficiaryNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        bankPhone: _bankPhoneNumber!,
        bankName: _selectedBank!,
        bankBranch: _selectedBranch!,
        businessRegImage: _businessRegImageUrl!,
        logoImage: _logoImageUrl!,
        nicFrontImage: _nicFrontImageUrl!,
        nicBackImage: _nicBackImageUrl!,
        openingHours: _openingHours,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SaloonDashboardScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration completed successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to sign up: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentDateTime = DateTime(2025, 5, 20, 11, 00); // Updated to current date and time
    final String formattedDateTime = DateFormat('hh:mm a Z \'on\' EEEE, MMMM d, yyyy')
        .format(currentDateTime.toUtc().add(const Duration(hours: 5, minutes: 30)));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _progressStep(isActive: _page >= 0),
                _progressStep(isActive: _page >= 1),
                _progressStep(isActive: _page >= 2),
                _progressStep(isActive: _page >= 3),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                formattedDateTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A1B9A),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _page = index),
                children: [
                  _buildOutletInfoStep(),
                  _buildContactInfoStep(),
                  _buildBusinessInfoStep(),
                  _buildBankInfoStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletInfoStep() {
    return Form(
      key: _outletInfoFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Outlet Information - Step 1 of 4",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB71C9B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Outlet Name *"),
            TextFormField(
              controller: _outletNameController,
              decoration: _inputDecoration("Outlet Name"),
              validator: (value) => _validateRequired(value, "outlet name"),
            ),
            _buildFieldLabel("E-mail Address *"),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration("E-mail Address", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildFieldLabel("Phone Number *"),
            Container(
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                initialCountryCode: 'LK',
                onChanged: (phone) => _phoneNumber = phone.completeNumber,
                validator: (p) => _validatePhoneNumber(p?.number),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: _isSubmitting
                  ? const CircularProgressIndicator(
                      color: Color(0xFF6A1B9A),
                    )
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MerchantLoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return Form(
      key: _contactInfoFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                InkWell(
                  onTap: back,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A0072),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Contact Information - Step 2 of 4",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB71C9B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Owner Name *"),
            TextFormField(
              controller: _ownerNameController,
              decoration: _inputDecoration("Owner Name"),
              validator: (value) => _validateRequired(value, "owner name"),
            ),
            _buildFieldLabel("Owner E-mail Address *"),
            TextFormField(
              controller: _ownerEmailController,
              decoration: _inputDecoration("Owner E-mail Address", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildFieldLabel("Owner Password *"),
            TextFormField(
              controller: _ownerPasswordController,
              decoration: _inputDecoration("Owner Password", icon: Icons.lock),
              obscureText: true,
              validator: _validatePassword,
            ),
            _buildFieldLabel("Outlet Manager's Name *"),
            TextFormField(
              controller: _managerNameController,
              decoration: _inputDecoration("Manager Name"),
              validator: (value) => _validateRequired(value, "manager name"),
            ),
            _buildFieldLabel("Manager's E-mail Address *"),
            TextFormField(
              controller: _managerEmailController,
              decoration: _inputDecoration("Manager E-mail Address", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildFieldLabel("Manager's Password *"),
            TextFormField(
              controller: _managerPasswordController,
              decoration: _inputDecoration("Manager Password", icon: Icons.lock),
              obscureText: true,
              validator: _validatePassword,
            ),
            _buildFieldLabel("Manager's Phone Number *"),
            Container(
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Phone Number',
                  errorBorder: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                initialCountryCode: 'LK',
                onChanged: (phone) => _managerPhoneNumber = phone.completeNumber,
                validator: (p) => _validatePhoneNumber(p?.number),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: _fieldDecoration(),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Opening hours saved successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Color(0xFF6A1B9A)),
                label: const Text(
                  "Set opening hours and date",
                  style: TextStyle(color: Color(0xFF6A1B9A)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: _isSubmitting
                  ? const CircularProgressIndicator(
                      color: Color(0xFF6A1B9A),
                    )
                  : ElevatedButton(
                      onPressed: next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: back,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A0072),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Business Information - Step 3 of 4",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB71C9B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("View agreement Template"),
              Icon(Icons.remove_red_eye, color: Colors.black),
            ],
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("Business Registration *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _businessRegUploaded,
            onPressed: () {
              setState(() {
                _businessRegUploaded = true;
                _businessRegImageUrl = _simulateFileUpload("business_reg");
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Business registration uploaded successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Tax Registered *",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: _taxRegistered,
                onChanged: (value) => setState(() => _taxRegistered = value ?? false),
              ),
              const Text("Yes"),
              const SizedBox(width: 10),
              Radio<bool>(
                value: false,
                groupValue: _taxRegistered,
                onChanged: (value) => setState(() => _taxRegistered = value ?? false),
              ),
              const Text("No"),
            ],
          ),
          _buildFieldLabel("Outlet Logo *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _logoUploaded,
            onPressed: () {
              setState(() {
                _logoUploaded = true;
                _logoImageUrl = _simulateFileUpload("logo");
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Outlet logo uploaded successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "National Identification *",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _buildFieldLabel("NIC Front *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _nicFrontUploaded,
            onPressed: () {
              setState(() {
                _nicFrontUploaded = true;
                _nicFrontImageUrl = _simulateFileUpload("nic_front");
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("NIC front uploaded successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          _buildFieldLabel("NIC Back *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _nicBackUploaded,
            onPressed: () {
              setState(() {
                _nicBackUploaded = true;
                _nicBackImageUrl = _simulateFileUpload("nic_back");
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("NIC back uploaded successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Color(0xFF6A1B9A))
                : ElevatedButton(
                    onPressed: next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBankInfoStep() {
    return Form(
      key: _bankInfoFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                InkWell(
                  onTap: back,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A0072),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Bank Information - Step 4 of 4",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB71C9B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Beneficiary Name *"),
            TextFormField(
              controller: _beneficiaryNameController,
              decoration: _inputDecoration("Beneficiary Name"),
              validator: (value) => _validateRequired(value, "beneficiary name"),
            ),
            _buildFieldLabel("Account Number *"),
            TextFormField(
              controller: _accountNumberController,
              decoration: _inputDecoration("Account Number"),
              keyboardType: TextInputType.number,
              validator: (value) => _validateRequired(value, "account number"),
            ),
            _buildFieldLabel("Phone Number *"),
            Container(
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Phone Number',
                  errorBorder: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                initialCountryCode: 'LK',
                onChanged: (phone) => _bankPhoneNumber = phone.completeNumber,
                validator: (p) => _validatePhoneNumber(p?.number),
              ),
            ),
            _buildFieldLabel("Bank Name *"),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: "Bank Name",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                value: _selectedBank,
                items: const [
                  DropdownMenuItem(value: "BOC", child: Text("Bank of Ceylon")),
                  DropdownMenuItem(value: "PB", child: Text("Peoples Bank")),
                  DropdownMenuItem(value: "HNB", child: Text("Hatton National Bank")),
                  DropdownMenuItem(value: "COMB", child: Text("Commercial Bank")),
                ],
                onChanged: (value) => setState(() => _selectedBank = value),
                validator: (value) => value == null ? 'Please select bank' : null,
              ),
            ),
            _buildFieldLabel("Bank Branch *"),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: "Bank Branch",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                value: _selectedBranch,
                items: _getBranchOptions(),
                onChanged: (value) => setState(() => _selectedBranch = value),
                validator: (value) => value == null ? 'Please select branch' : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Soft Copy of the Bank Statement Or Passbook *",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
          Center(
            child: _purpleUploadButton(
              "Upload",
              isUploaded: _bankStatementUploaded,
              onPressed: () {
                setState(() {
                  _bankStatementUploaded = true;
                  _bankStatementImageUrl = _simulateFileUpload("bank_statement");
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bank statement uploaded successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: _isSubmitting
                ? const CircularProgressIndicator(
                    color: Color(0xFF6A1B9A),
                  )
                : ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MerchantLoginPage()),
        );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Finish Registration",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

List<DropdownMenuItem<String>> _getBranchOptions() {
  if (_selectedBank == null) return [];

  switch (_selectedBank) {
    case "BOC":
      return [
        const DropdownMenuItem(value: "Colombo", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "Kandy", child: Text("Kandy")),
        const DropdownMenuItem(value: "Galle", child: Text("Galle")),
      ];
    case "PB":
      return [
        const DropdownMenuItem(value: "Colombo", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "Negombo", child: Text("Negombo")),
      ];
    case "HNB":
      return [
        const DropdownMenuItem(value: "Colombo", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "Kurunegala", child: Text("Kurunegala")),
      ];
    case "COMB":
      return [
        const DropdownMenuItem(value: "Colombo", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "Matara", child: Text("Matara")),
      ];
    default:
      return [];
  }
}

Widget _progressStep({required bool isActive}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    width: 35,
    height: 6,
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFF4A0072) : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

Widget _buildFieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF6A1B9A),
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint, {IconData? icon}) {
  return InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Color(0xFF4A0072), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.red, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF6A1B9A)) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
    filled: true,
    fillColor: const Color(0xFFF3E5F5),
  );
}

BoxDecoration _fieldDecoration() {
  return BoxDecoration(
    border: Border.all(color: const Color(0xFF6A1B9A), width: 1.2),
    borderRadius: BorderRadius.circular(25),
    color: const Color(0xFFF3E5F5),
  );
}

Widget _purpleUploadButton(
  String label, {
  required bool isUploaded,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isUploaded ? Colors.green : const Color(0xFF4A0072),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 4,
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isUploaded) const Icon(Icons.check, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          isUploaded ? "$label (Uploaded)" : label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}
}