import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'package:touch_me/merchant_page.dart';
import 'package:touch_me/saloon_dashboard_screen.dart';
import 'package:touch_me/saloon_map_screen.dart';
import 'package:touch_me/saloon_opening_hours_screen.dart';
import 'package:touch_me/services/merchant_auth_service.dart';
import 'package:touch_me/merchant_login_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';



class MerchantSignupMain extends StatefulWidget {
  const MerchantSignupMain({super.key});

  @override
  State<MerchantSignupMain> createState() => _MerchantSignupMainState();
}

class _MerchantSignupMainState extends State<MerchantSignupMain> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _isSubmitting = false;

  // Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an email address";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  // Phone number validator
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a phone number";
    }
    // You can add more advanced validation here if needed
    if (value.length < 7) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  // Required field validator
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter $fieldName";
    }
    return null;
  }

  // Form controllers
  final TextEditingController _outletNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _outletAddressController =
      TextEditingController(); // NEW
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPasswordController =
      TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerEmailController = TextEditingController();
  final TextEditingController _managerPasswordController =
      TextEditingController();
  final TextEditingController _beneficiaryNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

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

  // New fields for outlet picture
  bool _outletPictureUploaded = false;
  String? _outletPictureUrl;

  String? _selectedBank;
  String? _selectedBranch;

  // Simulated URLs for uploaded files (replace with actual file upload logic)
  String? _businessRegImageUrl;
  String? _logoImageUrl;
  String? _nicFrontImageUrl;
  String? _nicBackImageUrl;
  String? _bankStatementImageUrl;

  // Opening hours (hardcoded for now, as per API example)
  final Map<String, Map<String, String>> _openingHours = {
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
    _outletAddressController.dispose(); // NEW
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
        // New: Address and outlet picture validation
        if (_outletAddressController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enter an outlet address"),
              backgroundColor: Colors.red,
            ),
          );
          isValid = false;
        }
        if (!_outletPictureUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please upload outlet picture"),
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

  String _getSuccessMessageForPage(int page) {
    switch (page) {
      case 0:
        return "Outlet information saved!";
      case 1:
        return "Contact information saved!";
      case 2:
        return "Business information saved!";
      case 3:
        return "Bank information saved!";
      default:
        return "Step completed!";
    }
  }

  // ... keep all the validation and helper methods unchanged ...

  // Add this method to validate the business info step.
  // You can customize the validation logic as needed.
  bool _validateBusinessInfoStep() {
    // Example: Require NIC and business registration uploads
    bool isValid = true;
    if (!_nicFrontUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload NIC front image"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (!_nicBackUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload NIC back image"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (!_businessRegUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload business registration image"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (!_logoUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload logo image"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    return isValid;
  }

  // Add this method to validate the bank info step.
  bool _validateBankInfoStep() {
    bool isValid = true;
    if (_selectedBank == null || _selectedBank!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a bank"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (_selectedBranch == null || _selectedBranch!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a bank branch"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    if (!_bankStatementUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload bank statement"),
          backgroundColor: Colors.red,
        ),
      );
      isValid = false;
    }
    return isValid;
  }

  Future<void> _submitForm() async {
    if (!_bankInfoFormKey.currentState!.validate()) return;
    if (!_validateBankInfoStep()) return;
    if (_phoneNumber == null ||
        _managerPhoneNumber == null ||
        _bankPhoneNumber == null) {
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
        outletPicture: _outletPictureUrl!, // Added for required parameter
        outletAddress:
            _outletAddressController.text
                .trim(), // Added for required parameter
        ownerName: _ownerNameController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        ownerPhone: _phoneNumber!,
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
            MaterialPageRoute(
              builder:
                  (_) => MerchantPage(
                    userName: _ownerNameController.text.trim(),
                  ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Registration completed successfully!',
              ),
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

  Future<String?> uploadFileToFirebase({
    required String fileType,
    required String userId,
  }) async {
    PermissionStatus status;

    try {
      // Check platform and Android version
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }

      // Handle permission status
      if (status.isDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Permission denied. Please grant media/photos permission in settings.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Permission permanently denied. Please enable it in app settings.",
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return null;
      }

      // Proceed with file picking
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No file selected."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      final file = result.files.first;
      final fileName = file.name;

      // On mobile, file.bytes may be null; use file.path instead
      Uint8List? fileBytes = file.bytes;
      String? filePath = file.path;

      if (fileBytes == null && filePath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid file selected."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      try {
        final ref = FirebaseStorage.instance.ref(
          'merchant_uploads/$userId/${fileType}_$fileName',
        );

        UploadTask uploadTask;
        if (fileBytes != null) {
          // Web or cases where bytes are available
          uploadTask = ref.putData(fileBytes);
        } else {
          // Mobile: Use file path
          uploadTask = ref.putFile(File(filePath!));
        }

        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        return url;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Upload failed: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error during file upload: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }




  @override
  Widget build(BuildContext context) {
    // ... keep as is ...
    final DateTime currentDateTime = DateTime(2025, 5, 20, 11, 00);
    final String formattedDateTime = DateFormat(
      'hh:mm a Z \'on\' EEEE, MMMM d, yyyy',
    ).format(
      currentDateTime.toUtc().add(const Duration(hours: 5, minutes: 30)),
    );

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
                style: const TextStyle(fontSize: 14, color: Color(0xFF6A1B9A)),
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
            // NEW: Address Field
            _buildFieldLabel("Outlet Address *"),
            TextFormField(
              controller: _outletAddressController,
              decoration: _inputDecoration(
                "Outlet Address",
                icon: Icons.location_on,
              ),
              validator: (value) => _validateRequired(value, "outlet address"),
            ),
            // NEW: Outlet Picture Upload
            _buildFieldLabel("Outlet Picture *"),
            _purpleUploadButton(
              "Upload",
              isUploaded: _outletPictureUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "outlet_picture",
                  userId: _emailController.text.trim(), // Or another unique id
                );
                if (url != null) {
                  setState(() {
                    _outletPictureUploaded = true;
                    _outletPictureUrl = url;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Outlet picture uploaded successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to upload outlet picture."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed:
                    _isSubmitting
                        ? null
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SaloonMapScreen(),
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
                  "Create Pickup Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child:
                  _isSubmitting
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
          const DropdownMenuItem(
            value: "Kurunegala",
            child: Text("Kurunegala"),
          ),
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
      prefixIcon:
          icon != null ? Icon(icon, color: const Color(0xFF6A1B9A)) : null,
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

  // Simulate file upload and return a fake URL
  String _simulateFileUpload(String fileType) {
    // In a real app, this would be replaced with actual file upload logic.
    // For simulation, just return a dummy URL.
    return "https://example.com/uploads/$fileType.jpg";
  }

  // Add the missing _buildContactInfoStep method
  Widget _buildContactInfoStep() {
    return Form(
      key: _contactInfoFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Contact Information - Step 2 of 4",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB71C9B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Owner Name *"),
            TextFormField(
              controller: _ownerNameController,
              decoration: _inputDecoration("Owner Name"),
              validator: (value) => _validateRequired(value, "owner name"),
            ),
            _buildFieldLabel("Owner Email *"),
            TextFormField(
              controller: _ownerEmailController,
              decoration: _inputDecoration("Owner Email", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildFieldLabel("Owner Password *"),
            TextFormField(
              controller: _ownerPasswordController,
              decoration: _inputDecoration("Owner Password", icon: Icons.lock),
              obscureText: true,
              validator: (value) => _validateRequired(value, "owner password"),
            ),
            _buildFieldLabel("Manager Name *"),
            TextFormField(
              controller: _managerNameController,
              decoration: _inputDecoration("Manager Name"),
              validator: (value) => _validateRequired(value, "manager name"),
            ),
            _buildFieldLabel("Manager Email *"),
            TextFormField(
              controller: _managerEmailController,
              decoration: _inputDecoration("Manager Email", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _buildFieldLabel("Manager Password *"),
            TextFormField(
              controller: _managerPasswordController,
              decoration: _inputDecoration(
                "Manager Password",
                icon: Icons.lock,
              ),
              obscureText: true,
              validator:
                  (value) => _validateRequired(value, "manager password"),
            ),
            _buildFieldLabel("Manager Phone Number *"),
            Container(
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  hintText: 'Manager Phone Number',
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                initialCountryCode: 'LK',
                onChanged:
                    (phone) => _managerPhoneNumber = phone.completeNumber,
                validator: (p) => _validatePhoneNumber(p?.number),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator(
                        color: Color(0xFF6A1B9A),
                      )
                      : ElevatedButton(
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Add the missing _buildBusinessInfoStep method
  Widget _buildBusinessInfoStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Business Information - Step 3 of 4",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB71C9B),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel("NIC Front Image *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _nicFrontUploaded,
            onPressed: () async {
              final url = await uploadFileToFirebase(
                fileType: "nic_front",
                userId:
                    _emailController.text
                        .trim(), // Or any unique user/applicant ID
              );
              if (url != null) {
                setState(() {
                  _nicFrontUploaded = true;
                  _nicFrontImageUrl = url;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("NIC front image uploaded successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to upload NIC front image."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          _buildFieldLabel("NIC Back Image *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _nicBackUploaded,
            onPressed: () async {
              final url = await uploadFileToFirebase(
                fileType: "nic_back",
                userId: _emailController.text.trim(), // Use a unique identifier
              );
              if (url != null) {
                setState(() {
                  _nicBackUploaded = true;
                  _nicBackImageUrl = url;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("NIC back image uploaded successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to upload NIC back image."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          _buildFieldLabel("Business Registration Image *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _businessRegUploaded,
            onPressed: () async {
              final url = await uploadFileToFirebase(
                fileType: "business_reg",
                userId: _emailController.text.trim(), // Use a unique identifier
              );
              if (url != null) {
                setState(() {
                  _businessRegUploaded = true;
                  _businessRegImageUrl = url;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Business registration image uploaded successfully!",
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Failed to upload business registration image.",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          _buildFieldLabel("Logo Image *"),
          _purpleUploadButton(
            "Upload",
            isUploaded: _logoUploaded,
            onPressed: () async {
              final url = await uploadFileToFirebase(
                fileType: "logo",
                userId: _emailController.text.trim(), // Use any unique value
              );
              if (url != null) {
                setState(() {
                  _logoUploaded = true;
                  _logoImageUrl = url;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logo image uploaded successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to upload logo image."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 20),
          Center(
            child:
                _isSubmitting
                    ? const CircularProgressIndicator(color: Color(0xFF6A1B9A))
                    : ElevatedButton(
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Add the missing _buildBankInfoStep method
  Widget _buildBankInfoStep() {
    return Form(
      key: _bankInfoFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Bank Information - Step 4 of 4",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB71C9B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Beneficiary Name *"),
            TextFormField(
              controller: _beneficiaryNameController,
              decoration: _inputDecoration("Beneficiary Name"),
              validator:
                  (value) => _validateRequired(value, "beneficiary name"),
            ),
            _buildFieldLabel("Account Number *"),
            TextFormField(
              controller: _accountNumberController,
              decoration: _inputDecoration("Account Number"),
              keyboardType: TextInputType.number,
              validator: (value) => _validateRequired(value, "account number"),
            ),
            _buildFieldLabel("Bank Name *"),
            DropdownButtonFormField<String>(
              value: _selectedBank,
              items: const [
                DropdownMenuItem(value: "BOC", child: Text("Bank of Ceylon")),
                DropdownMenuItem(value: "PB", child: Text("Peoples Bank")),
                DropdownMenuItem(
                  value: "HNB",
                  child: Text("Hatton National Bank"),
                ),
                DropdownMenuItem(value: "COMB", child: Text("Commercial Bank")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedBank = value;
                  _selectedBranch = null;
                });
              },
              decoration: _inputDecoration("Select Bank"),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? "Please select a bank"
                          : null,
            ),
            _buildFieldLabel("Bank Branch *"),
            DropdownButtonFormField<String>(
              value: _selectedBranch,
              items: _getBranchOptions(),
              onChanged: (value) {
                setState(() {
                  _selectedBranch = value;
                });
              },
              decoration: _inputDecoration("Select Branch"),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? "Please select a branch"
                          : null,
            ),
            _buildFieldLabel("Bank Phone Number *"),
            Container(
              decoration: _fieldDecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IntlPhoneField(
                decoration: const InputDecoration(
                  hintText: 'Bank Phone Number',
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFFF3E5F5),
                ),
                initialCountryCode: 'LK',
                onChanged: (phone) => _bankPhoneNumber = phone.completeNumber,
                validator: (p) => _validatePhoneNumber(p?.number),
              ),
            ),
            _buildFieldLabel("Bank Statement *"),
            _purpleUploadButton(
              "Upload",
              isUploaded: _bankStatementUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "bank_statement",
                  userId: _emailController.text.trim(), // Use any unique value
                );
                if (url != null) {
                  setState(() {
                    _bankStatementUploaded = true;
                    _bankStatementImageUrl = url;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bank statement uploaded successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to upload bank statement."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),
            Center(
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator(
                        color: Color(0xFF6A1B9A),
                      )
                      : ElevatedButton(
                        onPressed: _submitForm,
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
                          "Submit",
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
}
