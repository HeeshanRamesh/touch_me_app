import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'package:touch_me/pages/merchant_login_page.dart';
import 'package:touch_me/pages/saloon_map_screen.dart';
import 'package:touch_me/pages/saloon_opening_hours_screen.dart';
import 'package:touch_me/services/merchant_auth_service.dart';
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
  bool _termsAccepted = false; // NEW: State for Terms & Conditions checkbox

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
  final TextEditingController _outletAddressController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPasswordController = TextEditingController();
  // final TextEditingController _managerNameController = TextEditingController();
  // final TextEditingController _managerEmailController = TextEditingController();
  // final TextEditingController _managerPasswordController = TextEditingController();
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  // Form keys for validation
  final GlobalKey<FormState> _outletInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bankInfoFormKey = GlobalKey<FormState>();

  // State for uploads and selections
  String? _phoneNumber;
  //String? _managerPhoneNumber;
  //String? _bankPhoneNumber;
  bool _taxRegistered = false;
  bool _nicFrontUploaded = false;
  bool _nicBackUploaded = false;
  bool _businessRegUploaded = false;
  bool _logoUploaded = false;
  bool _bankStatementUploaded = false;
  bool _outletPictureUploaded = false;
  String? _outletPictureUrl;
  String? _selectedBank;
  String? _selectedBranch;
  String? _businessRegImageUrl;
  String? _logoImageUrl;
  String? _nicFrontImageUrl;
  String? _nicBackImageUrl;
  String? _bankStatementImageUrl;
  bool _hasAgreed = false;
  bool _isTaxRegisteredYes = false;
  bool _isTaxRegisteredNo = false;


  // Opening hours
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
    _outletAddressController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPasswordController.dispose();
    // _managerNameController.dispose();
    // _managerEmailController.dispose();
    // _managerPasswordController.dispose();
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
      
        // isValid = _contactInfoFormKey.currentState?.validate() ?? false;
        // if (isValid && _ownerPhoneNumber == null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Please enter a valid Owner phone number"),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   isValid = false;
        // }
        break;
      case 2:
        isValid = _validateBusinessInfoStep();
        break;
      case 3:
      //   isValid = _bankInfoFormKey.currentState?.validate() ?? false;
      //  if (isValid) isValid = _validateBankInfoStep();
      //   if (isValid && _bankPhoneNumber == null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text("Please enter a valid bank phone number"),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //     isValid = false;
      //   }
        if (!_termsAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You must agree to the Terms & Conditions"),
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

  bool _validateBusinessInfoStep() {
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
    if (_phoneNumber == null){
        //_OwnerPhoneNumber == null){
        //_bankPhoneNumber == null) {
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
    // if (!_termsAccepted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("You must agree to the Terms & Conditions"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() => _isSubmitting = true);

    try {
      final result = await MerchantAuthService().signupMerchant(
        outletName: _outletNameController.text.trim(),
        outletEmail: _emailController.text.trim(),
        outletPhone: _phoneNumber!,
        outletPicture: _outletPictureUrl!,
        outletAddress: _outletAddressController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        ownerPhone: _phoneNumber!,
        ownerPassword: _ownerPasswordController.text.trim(),
        // managerName: _managerNameController.text.trim(),
        // managerEmail: _managerEmailController.text.trim(),
        // managerPhone: _managerPhoneNumber!,
        // managerPassword: _managerPasswordController.text.trim(),
        beneficiaryName: _beneficiaryNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        //bankPhone: _bankPhoneNumber!,
        bankName: _selectedBank!,
        bankBranch: _selectedBranch!,
        businessRegImage: _businessRegImageUrl!,
        logoImage: _logoImageUrl!,
        nicFrontImage: _nicFrontImageUrl!,
        nicBackImage: _nicBackImageUrl!,
        openingHours: _openingHours,
      );

      // Option 1: Show success dialog instead of immediately navigating
if (result['success'] == true) {
  if (mounted) {
    // Show success dialog first
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              // Success message
              const Text(
                'Registration successfully completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'as a merchant',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // OK button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MerchantLoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          uploadTask = ref.putData(fileBytes);
        } else {
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

  // NEW: Method to show Terms & Conditions in a scrollable modal
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A1B9A),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                          "TouchMe - Terms & Conditions and Refund Policy for Merchants\n\n"
                          "Effective Date: July 01, 2025\n\n"
                          "By registering as a merchant on the TouchMe platform, you agree to the following Terms & Conditions, including our refund and cancellation policies. These terms govern your relationship with SmartTouch Digital Solutions (P) Ltd.\n\n"
                          "1. Acceptance of Terms\n\n"
                          "By using TouchMe, you confirm that you agree to these Terms. If you do not agree, you must not register as a merchant.\n\n"
                          "2. Merchant Responsibilities\n\n"
                          "- Maintain accurate service listings, pricing, and availability.\n"
                          "- Honor all confirmed bookings, or notify clients promptly of unavoidable changes.\n"
                          "- Provide services at a professional standard.\n\n"
                          "3. Booking and Cancellation Policy\n\n"
                          "- You must define your cancellation policy during onboarding.\n"
                          "- Customers may cancel within your defined window without penalty.\n"
                          "- You may charge a 'no-show fee' if a client cancels too late or does not show up.\n\n"
                          "4. Refund Policy\n\n"
                          "- Refunds will only be provided for missed services, duplicate payments, or technical issues.\n"
                          "- Requests for refunds must be submitted within 48 hours of the appointment.\n"
                          "- Refunds will be processed through TouchMe and may take 5-7 business days.\n\n"
                          "5. Dispute Resolution\n\n"
                          "- TouchMe will act as a neutral party in disputes.\n"
                          "- We will evaluate both sides and issue a fair resolution.\n"
                          "- The final decision rests with TouchMe's support team.\n\n"
                          "6. Service Fees and Payouts\n\n"
                          "- Commissions will be deducted per the agreed terms.\n"
                          "- Payouts are made weekly, net of fees.\n\n"
                          "7. Privacy & Data Protection\n\n"
                          "TouchMe is committed to protecting the privacy and confidentiality of all users, including both clients and merchants. All personal information and data collected through the TouchMe app, including but not limited to names, contact details, appointment history, and business information, will be stored securely and treated with strict confidentiality.\n\n"
                          "We hereby assure you that your data will not be shared, sold, rented, or disclosed to any third parties without your explicit consent, except as required by law or to comply with legal obligations. Our systems are designed with appropriate security measures to safeguard your data against unauthorized access, misuse, or disclosure.\n\n"
                          "By using the TouchMe app, you agree to our commitment to maintaining your privacy and trust.\n\n"
                          "8. Termination\n\n"
                          "- Breach of terms may result in account suspension or termination.\n"
                          "- Merchants may exit the platform with 7 days' notice.\n\n"
                          "9. Changes to Terms\n\n"
                          "- We reserve the right to update these terms. Continued use of the app indicates acceptance.\n\n"
                          "For support or questions, contact:\n\n"
                          "Email: digitaltouch@outlook.com\n"
                          "Hotline: +94 777 763 5225\n\n"
                          "© 2025 SmartTouch Digital Solutions (Pvt) Ltd. All rights reserved.",
                          style: TextStyle(fontSize: 14),
                        ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  setState(() {
                    _hasAgreed = true;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Accept & Agree"),
              ),
             TextButton(
              onPressed: () {
                setState(() {
                  _hasAgreed = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
                style: TextStyle(color: Color(0xFF6A1B9A)),
              ),
            ),
            
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentDateTime = DateTime.now();
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
              decoration: _inputDecoration("Outlet Name", icon: Icons.store),
              validator: (value) => _validateRequired(value, "outlet name"),
              textAlign: TextAlign.center,
            ),
             _buildFieldLabel("Outlet Address *"),
            TextFormField(
              controller: _outletAddressController,
              decoration: _inputDecoration(
                "Outlet Address",
                icon: Icons.location_on,

              ),
              validator: (value) => _validateRequired(value, "outlet address"),
              textAlign: TextAlign.center,
            ),
            _buildFieldLabel("E-mail Address *"),
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration("E-mail Address", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              textAlign: TextAlign.center,
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
            _buildFieldLabel("Outlet Picture *"),
            _purpleUploadButton(
              "Upload",
              isUploaded: _outletPictureUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "outlet_picture",
                  userId: _emailController.text.trim(),
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
                onPressed: _isSubmitting
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
                    horizontal: 30,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  "Set Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text( "Need Help with registation?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              
            
            ),
            const SizedBox(height: 10),
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
                            "Sign Up",
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
    case "BOC": // Bank of Ceylon
      return [
        // Colombo District
        const DropdownMenuItem(value: "BOC_Colombo_Main", child: Text("Colombo Main Branch")),
        const DropdownMenuItem(value: "BOC_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "BOC_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "BOC_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "BOC_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "BOC_Colombo_Maharagama", child: Text("Maharagama")),
        const DropdownMenuItem(value: "BOC_Colombo_Nugegoda", child: Text("Nugegoda")),
        const DropdownMenuItem(value: "BOC_Colombo_Wellawatta", child: Text("Wellawatta")),
        const DropdownMenuItem(value: "BOC_Colombo_Kotte", child: Text("Kotte")),
        const DropdownMenuItem(value: "BOC_Colombo_Rajagiriya", child: Text("Rajagiriya")),
        const DropdownMenuItem(value: "BOC_Colombo_Borella", child: Text("Borella")),
        const DropdownMenuItem(value: "BOC_Colombo_Maradana", child: Text("Maradana")),
        const DropdownMenuItem(value: "BOC_Colombo_Grandpass", child: Text("Grandpass")),
        const DropdownMenuItem(value: "BOC_Colombo_Kelaniya", child: Text("Kelaniya")),
        const DropdownMenuItem(value: "BOC_Colombo_Kirulapone", child: Text("Kirulapone")),
        const DropdownMenuItem(value: "BOC_Colombo_Kolonnawa", child: Text("Kolonnawa")),
        const DropdownMenuItem(value: "BOC_Colombo_Kotahena", child: Text("Kotahena")),
        const DropdownMenuItem(value: "BOC_Colombo_Mount_Lavinia", child: Text("Mount Lavinia")),
        const DropdownMenuItem(value: "BOC_Colombo_Moratuwa", child: Text("Moratuwa")),
        const DropdownMenuItem(value: "BOC_Colombo_Piliyandala", child: Text("Piliyandala")),
        const DropdownMenuItem(value: "BOC_Colombo_Homagama", child: Text("Homagama")),
        const DropdownMenuItem(value: "BOC_Colombo_Pannipitiya", child: Text("Pannipitiya")),
        const DropdownMenuItem(value: "BOC_Colombo_Kaduwela", child: Text("Kaduwela")),
        const DropdownMenuItem(value: "BOC_Colombo_Malabe", child: Text("Malabe")),
        const DropdownMenuItem(value: "BOC_Colombo_Battaramulla", child: Text("Battaramulla")),
        const DropdownMenuItem(value: "BOC_Colombo_Athurugiriya", child: Text("Athurugiriya")),
        const DropdownMenuItem(value: "BOC_Colombo_Kottawa", child: Text("Kottawa")),
        const DropdownMenuItem(value: "BOC_Colombo_Kohuwala", child: Text("Kohuwala")),
        const DropdownMenuItem(value: "BOC_Colombo_Angoda", child: Text("Angoda")),
        const DropdownMenuItem(value: "BOC_Colombo_Thalawathugoda", child: Text("Thalawathugoda")),
        
        // Gampaha District
        const DropdownMenuItem(value: "BOC_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "BOC_Gampaha_Main", child: Text("Gampaha Main")),
        const DropdownMenuItem(value: "BOC_Katunayake", child: Text("Katunayake")),
        const DropdownMenuItem(value: "BOC_Ja_Ela", child: Text("Ja-Ela")),
        const DropdownMenuItem(value: "BOC_Wattala", child: Text("Wattala")),
        const DropdownMenuItem(value: "BOC_Kelaniya_2", child: Text("Kelaniya Branch 2")),
        const DropdownMenuItem(value: "BOC_Minuwangoda", child: Text("Minuwangoda")),
        const DropdownMenuItem(value: "BOC_Veyangoda", child: Text("Veyangoda")),
        const DropdownMenuItem(value: "BOC_Kiribathgoda", child: Text("Kiribathgoda")),
        const DropdownMenuItem(value: "BOC_Kandana", child: Text("Kandana")),
        const DropdownMenuItem(value: "BOC_Divulapitiya", child: Text("Divulapitiya")),
        const DropdownMenuItem(value: "BOC_Mirigama", child: Text("Mirigama")),
        const DropdownMenuItem(value: "BOC_Attanagalla", child: Text("Attanagalla")),
        const DropdownMenuItem(value: "BOC_Nittambuwa", child: Text("Nittambuwa")),
        const DropdownMenuItem(value: "BOC_Dompe", child: Text("Dompe")),
        const DropdownMenuItem(value: "BOC_Ragama", child: Text("Ragama")),
        const DropdownMenuItem(value: "BOC_Biyagama", child: Text("Biyagama")),
        const DropdownMenuItem(value: "BOC_Mahara", child: Text("Mahara")),
        const DropdownMenuItem(value: "BOC_Seeduwa", child: Text("Seeduwa")),
        const DropdownMenuItem(value: "BOC_Liyanagemulla", child: Text("Liyanagemulla")),
        
        // Kandy District
        const DropdownMenuItem(value: "BOC_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "BOC_Kandy_Peradeniya", child: Text("Peradeniya")),
        const DropdownMenuItem(value: "BOC_Kandy_Katugastota", child: Text("Katugastota")),
        const DropdownMenuItem(value: "BOC_Kandy_Gampola", child: Text("Gampola")),
        const DropdownMenuItem(value: "BOC_Kandy_Nawalapitiya", child: Text("Nawalapitiya")),
        const DropdownMenuItem(value: "BOC_Kandy_Kadugannawa", child: Text("Kadugannawa")),
        const DropdownMenuItem(value: "BOC_Kandy_Pilimatalawa", child: Text("Pilimatalawa")),
        const DropdownMenuItem(value: "BOC_Kandy_Akurana", child: Text("Akurana")),
        const DropdownMenuItem(value: "BOC_Kandy_Digana", child: Text("Digana")),
        const DropdownMenuItem(value: "BOC_Kandy_Teldeniya", child: Text("Teldeniya")),
        const DropdownMenuItem(value: "BOC_Kandy_Wattegama", child: Text("Wattegama")),
        const DropdownMenuItem(value: "BOC_Kandy_Kundasale", child: Text("Kundasale")),
        const DropdownMenuItem(value: "BOC_Kandy_Harispattuwa", child: Text("Harispattuwa")),
        const DropdownMenuItem(value: "BOC_Kandy_Panvila", child: Text("Panvila")),
        const DropdownMenuItem(value: "BOC_Kandy_Deltota", child: Text("Deltota")),
        const DropdownMenuItem(value: "BOC_Kandy_Hewaheta", child: Text("Hewaheta")),
        const DropdownMenuItem(value: "BOC_Kandy_Medadumbara", child: Text("Medadumbara")),
        const DropdownMenuItem(value: "BOC_Kandy_Pasbage", child: Text("Pasbage")),
        const DropdownMenuItem(value: "BOC_Kandy_Poojapitiya", child: Text("Poojapitiya")),
        const DropdownMenuItem(value: "BOC_Kandy_Udadumbara", child: Text("Udadumbara")),
        
        // Galle District
        const DropdownMenuItem(value: "BOC_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "BOC_Galle_Hikkaduwa", child: Text("Hikkaduwa")),
        const DropdownMenuItem(value: "BOC_Galle_Ambalangoda", child: Text("Ambalangoda")),
        const DropdownMenuItem(value: "BOC_Galle_Bentota", child: Text("Bentota")),
        const DropdownMenuItem(value: "BOC_Galle_Kosgoda", child: Text("Kosgoda")),
        const DropdownMenuItem(value: "BOC_Galle_Balapitiya", child: Text("Balapitiya")),
        const DropdownMenuItem(value: "BOC_Galle_Elpitiya", child: Text("Elpitiya")),
        const DropdownMenuItem(value: "BOC_Galle_Pitigala", child: Text("Pitigala")),
        const DropdownMenuItem(value: "BOC_Galle_Tawalama", child: Text("Tawalama")),
        const DropdownMenuItem(value: "BOC_Galle_Baddegama", child: Text("Baddegama")),
        const DropdownMenuItem(value: "BOC_Galle_Neluwa", child: Text("Neluwa")),
        const DropdownMenuItem(value: "BOC_Galle_Nagoda", child: Text("Nagoda")),
        const DropdownMenuItem(value: "BOC_Galle_Batapola", child: Text("Batapola")),
        const DropdownMenuItem(value: "BOC_Galle_Imaduwa", child: Text("Imaduwa")),
        const DropdownMenuItem(value: "BOC_Galle_Habaraduwa", child: Text("Habaraduwa")),
        const DropdownMenuItem(value: "BOC_Galle_Unawatuna", child: Text("Unawatuna")),
        const DropdownMenuItem(value: "BOC_Galle_Yakkalamulla", child: Text("Yakkalamulla")),
        
        // Matara District
        const DropdownMenuItem(value: "BOC_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "BOC_Matara_Weligama", child: Text("Weligama")),
        const DropdownMenuItem(value: "BOC_Matara_Mirissa", child: Text("Mirissa")),
        const DropdownMenuItem(value: "BOC_Matara_Akuressa", child: Text("Akuressa")),
        const DropdownMenuItem(value: "BOC_Matara_Hakmana", child: Text("Hakmana")),
        const DropdownMenuItem(value: "BOC_Matara_Kamburupitiya", child: Text("Kamburupitiya")),
        const DropdownMenuItem(value: "BOC_Matara_Devinuwara", child: Text("Devinuwara")),
        const DropdownMenuItem(value: "BOC_Matara_Dickwella", child: Text("Dickwella")),
        const DropdownMenuItem(value: "BOC_Matara_Tangalle", child: Text("Tangalle")),
        const DropdownMenuItem(value: "BOC_Matara_Beliatta", child: Text("Beliatta")),
        const DropdownMenuItem(value: "BOC_Matara_Urubokka", child: Text("Urubokka")),
        const DropdownMenuItem(value: "BOC_Matara_Pitabeddara", child: Text("Pitabeddara")),
        const DropdownMenuItem(value: "BOC_Matara_Pasgoda", child: Text("Pasgoda")),
        const DropdownMenuItem(value: "BOC_Matara_Thihagoda", child: Text("Thihagoda")),
        const DropdownMenuItem(value: "BOC_Matara_Kotapola", child: Text("Kotapola")),
        
        // Kurunegala District
        const DropdownMenuItem(value: "BOC_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Puttalam", child: Text("Puttalam")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Chilaw", child: Text("Chilaw")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Kuliyapitiya", child: Text("Kuliyapitiya")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Narammala", child: Text("Narammala")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Wariyapola", child: Text("Wariyapola")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Pannala", child: Text("Pannala")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Giriulla", child: Text("Giriulla")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Polgahawela", child: Text("Polgahawela")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Alawwa", child: Text("Alawwa")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Mawathagama", child: Text("Mawathagama")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Dankotuwa", child: Text("Dankotuwa")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Bingiriya", child: Text("Bingiriya")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Nikaweratiya", child: Text("Nikaweratiya")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Hettipola", child: Text("Hettipola")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Ibbagamuwa", child: Text("Ibbagamuwa")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Udubaddawa", child: Text("Udubaddawa")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Mahawa", child: Text("Mahawa")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Kobeigane", child: Text("Kobeigane")),
        const DropdownMenuItem(value: "BOC_Kurunegala_Ridigama", child: Text("Ridigama")),
        
        // Anuradhapura District
        const DropdownMenuItem(value: "BOC_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Kekirawa", child: Text("Kekirawa")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Eppawala", child: Text("Eppawala")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Habarana", child: Text("Habarana")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Mihintale", child: Text("Mihintale")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Medawachchiya", child: Text("Medawachchiya")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Horowpothana", child: Text("Horowpothana")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Galenbindunuwewa", child: Text("Galenbindunuwewa")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Thirappane", child: Text("Thirappane")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Nochchiyagama", child: Text("Nochchiyagama")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Rambewa", child: Text("Rambewa")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Talawa", child: Text("Talawa")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Palagala", child: Text("Palagala")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Kahatagasdigiliya", child: Text("Kahatagasdigiliya")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Galnewa", child: Text("Galnewa")),
        const DropdownMenuItem(value: "BOC_Anuradhapura_Rajanganaya", child: Text("Rajanganaya")),
        
        // Polonnaruwa District
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Main", child: Text("Polonnaruwa Main")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Kaduruwela", child: Text("Kaduruwela")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Medirigiriya", child: Text("Medirigiriya")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Hingurakgoda", child: Text("Hingurakgoda")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Dimbulagala", child: Text("Dimbulagala")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Welikanda", child: Text("Welikanda")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Lankapura", child: Text("Lankapura")),
        const DropdownMenuItem(value: "BOC_Polonnaruwa_Thamankaduwa", child: Text("Thamankaduwa")),
        
        // Trincomalee District
        const DropdownMenuItem(value: "BOC_Trincomalee_Main", child: Text("Trincomalee Main")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Kinniya", child: Text("Kinniya")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Nilaveli", child: Text("Nilaveli")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Mutur", child: Text("Mutur")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Kantale", child: Text("Kantale")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Gomarankadawala", child: Text("Gomarankadawala")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Seruvila", child: Text("Seruvila")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Padavi_Sripo", child: Text("Padavi Sripo")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Verugal", child: Text("Verugal")),
        const DropdownMenuItem(value: "BOC_Trincomalee_Thambalagamuwa", child: Text("Thambalagamuwa")),
        
        // Batticaloa District
        const DropdownMenuItem(value: "BOC_Batticaloa_Main", child: Text("Batticaloa Main")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Kaluwanchikudy", child: Text("Kaluwanchikudy")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Valachchenai", child: Text("Valachchenai")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Eravur", child: Text("Eravur")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Kattankudy", child: Text("Kattankudy")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Oddamavadi", child: Text("Oddamavadi")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Chenkalady", child: Text("Chenkalady")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Pasikudah", child: Text("Pasikudah")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Koralaipattu", child: Text("Koralaipattu")),
        const DropdownMenuItem(value: "BOC_Batticaloa_Manmunai", child: Text("Manmunai")),
        
        // Ampara District
        const DropdownMenuItem(value: "BOC_Ampara_Main", child: Text("Ampara Main")),
        const DropdownMenuItem(value: "BOC_Ampara_Kalmunai", child: Text("Kalmunai")),
        const DropdownMenuItem(value: "BOC_Ampara_Akkaraipattu", child: Text("Akkaraipattu")),
        const DropdownMenuItem(value: "BOC_Ampara_Sammanthurai", child: Text("Sammanthurai")),
        const DropdownMenuItem(value: "BOC_Ampara_Pottuvil", child: Text("Pottuvil")),
        const DropdownMenuItem(value: "BOC_Ampara_Arugam_Bay", child: Text("Arugam Bay")),
        const DropdownMenuItem(value: "BOC_Ampara_Uhana", child: Text("Uhana")),
        const DropdownMenuItem(value: "BOC_Ampara_Mahaoya", child: Text("Mahaoya")),
        const DropdownMenuItem(value: "BOC_Ampara_Damana", child: Text("Damana")),
        const DropdownMenuItem(value: "BOC_Ampara_Sainthamaruthu", child: Text("Sainthamaruthu")),
        const DropdownMenuItem(value: "BOC_Ampara_Ninthavur", child: Text("Ninthavur")),
        const DropdownMenuItem(value: "BOC_Ampara_Lahugala", child: Text("Lahugala")),
        const DropdownMenuItem(value: "BOC_Ampara_Navithanveli", child: Text("Navithanveli")),
        
        // Jaffna District
        const DropdownMenuItem(value: "BOC_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "BOC_Jaffna_Nallur", child: Text("Nallur")),
        const DropdownMenuItem(value: "BOC_Jaffna_Chavakachcheri", child: Text("Chavakachcheri")),
        const DropdownMenuItem(value: "BOC_Jaffna_Point_Pedro", child: Text("Point Pedro")),
        const DropdownMenuItem(value: "BOC_Jaffna_Kayts", child: Text("Kayts")),
        const DropdownMenuItem(value: "BOC_Jaffna_Karainagar", child: Text("Karainagar")),
        const DropdownMenuItem(value: "BOC_Jaffna_Velanai", child: Text("Velanai")),
        const DropdownMenuItem(value: "BOC_Jaffna_Delft", child: Text("Delft")),
        const DropdownMenuItem(value: "BOC_Jaffna_Thellipalai", child: Text("Thellipalai")),
        const DropdownMenuItem(value: "BOC_Jaffna_Sandilipay", child: Text("Sandilipay")),
        const DropdownMenuItem(value: "BOC_Jaffna_Kopay", child: Text("Kopay")),
        const DropdownMenuItem(value: "BOC_Jaffna_Manipay", child: Text("Manipay")),
        const DropdownMenuItem(value: "BOC_Jaffna_Uduvil", child: Text("Uduvil")),
        
        // Vavuniya District
        const DropdownMenuItem(value: "BOC_Vavuniya_Main", child: Text("Vavuniya Main")),
        const DropdownMenuItem(value: "BOC_Vavuniya_Cheddikulam", child: Text("Cheddikulam")),
        const DropdownMenuItem(value: "BOC_Vavuniya_Nedunkerni", child: Text("Nedunkerni")),
        const DropdownMenuItem(value: "BOC_Vavuniya_Vavuniya_South", child: Text("Vavuniya South")),
        const DropdownMenuItem(value: "BOC_Vavuniya_Omanthai", child: Text("Omanthai")),
        
        // Mannar District
        const DropdownMenuItem(value: "BOC_Mannar_Main", child: Text("Mannar Main")),
        const DropdownMenuItem(value: "BOC_Mannar_Nanattan", child: Text("Nanattan")),
        const DropdownMenuItem(value: "BOC_Mannar_Madhu", child: Text("Madhu")),
        const DropdownMenuItem(value: "BOC_Mannar_Musali", child: Text("Musali")),
        
        // Mullaitivu District
        const DropdownMenuItem(value: "BOC_Mullaitivu_Main", child: Text("Mullaitivu Main")),
        const DropdownMenuItem(value: "BOC_Mullaitivu_Puthukudiyiruppu", child: Text("Puthukudiyiruppu")),
        const DropdownMenuItem(value: "BOC_Mullaitivu_Oddusuddan", child: Text("Oddusuddan")),
        const DropdownMenuItem(value: "BOC_Mullaitivu_Kokkilai", child: Text("Kokkilai")),
        
        // Ratnapura District
        const DropdownMenuItem(value: "BOC_Ratnapura_Main", child: Text("Ratnapura Main")),
        const DropdownMenuItem(value: "BOC_Ratnapura_Embilipitiya", child: Text("Embilipitiya")),
        const DropdownMenuItem(value: "BOC_Ratnapura_Balangoda", child: Text("Balangoda")),
        const DropdownMenuItem(value: "BOC_Ratnapura_Pelmadulla", child: Text("Pelmadulla")),
        const DropdownMenuItem(value: "BOC_Ratnapura_Kuruwita", child: Text("Kuruwita")),

      ];
      
    case "PB": // People's Bank
      return [
        const DropdownMenuItem(value: "PB_Colombo_Main", child: Text("Colombo Main - Sir Chittampalam A. Gardiner Mw")),
        const DropdownMenuItem(value: "PB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "PB_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "PB_Colombo_Wellawatta", child: Text("Wellawatta")),
        const DropdownMenuItem(value: "PB_Colombo_Rajagiriya", child: Text("Rajagiriya")),
        const DropdownMenuItem(value: "PB_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "PB_Negombo_Katunayake", child: Text("Katunayake")),
        const DropdownMenuItem(value: "PB_Gampaha_Main", child: Text("Gampaha Main")),
        const DropdownMenuItem(value: "PB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "PB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "PB_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "PB_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "PB_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "PB_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "PB_Batticaloa_Main", child: Text("Batticaloa Main")),
      ];
      
    case "COMB": // Commercial Bank of Ceylon
      return [
        const DropdownMenuItem(value: "COMB_Colombo_Main", child: Text("Colombo Main - Bristol Street")),
        const DropdownMenuItem(value: "COMB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "COMB_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "COMB_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "COMB_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "COMB_Colombo_Nugegoda", child: Text("Nugegoda")),
        const DropdownMenuItem(value: "COMB_Colombo_Maharagama", child: Text("Maharagama")),
        const DropdownMenuItem(value: "COMB_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "COMB_Negombo_Dankotuwa", child: Text("Dankotuwa")),
        const DropdownMenuItem(value: "COMB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "COMB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "COMB_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "COMB_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "COMB_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "COMB_Trincomalee_Main", child: Text("Trincomalee Main")),
        const DropdownMenuItem(value: "COMB_Batticaloa_Main", child: Text("Batticaloa Main")),
        const DropdownMenuItem(value: "COMB_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "COMB_Ratnapura_Main", child: Text("Ratnapura Main")),
        const DropdownMenuItem(value: "COMB_Badulla_Main", child: Text("Badulla Main")),
      ];
      
    case "HNB": // Hatton National Bank
      return [
        const DropdownMenuItem(value: "HNB_Colombo_Main", child: Text("Colombo Main - HNB Towers")),
        const DropdownMenuItem(value: "HNB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "HNB_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "HNB_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "HNB_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "HNB_Colombo_Nugegoda", child: Text("Nugegoda")),
        const DropdownMenuItem(value: "HNB_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "HNB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "HNB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "HNB_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "HNB_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "HNB_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "HNB_Trincomalee_Main", child: Text("Trincomalee Main")),
        const DropdownMenuItem(value: "HNB_Batticaloa_Main", child: Text("Batticaloa Main")),
        const DropdownMenuItem(value: "HNB_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "HNB_Ratnapura_Main", child: Text("Ratnapura Main")),
        const DropdownMenuItem(value: "HNB_Badulla_Main", child: Text("Badulla Main")),
      ];
      
    case "SB": // Seylan Bank
      return [
        const DropdownMenuItem(value: "SB_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "SB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "SB_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "SB_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "SB_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "SB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "SB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "SB_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "SB_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "SB_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "SB_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "SB_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "SB_Batticaloa_Main", child: Text("Batticaloa Main")),
        const DropdownMenuItem(value: "SB_Ratnapura_Main", child: Text("Ratnapura Main")),
      ];
      
    case "SAMPATH": // Sampath Bank
      return [
        const DropdownMenuItem(value: "SAMPATH_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "SAMPATH_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "SAMPATH_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "SAMPATH_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "SAMPATH_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "SAMPATH_Colombo_Nugegoda", child: Text("Nugegoda")),
        const DropdownMenuItem(value: "SAMPATH_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "SAMPATH_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "SAMPATH_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "SAMPATH_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "SAMPATH_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "SAMPATH_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "SAMPATH_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "SAMPATH_Batticaloa_Main", child: Text("Batticaloa Main")),
        const DropdownMenuItem(value: "SAMPATH_Ratnapura_Main", child: Text("Ratnapura Main")),
      ];
      
    case "DFCC": // DFCC Bank
      return [
        const DropdownMenuItem(value: "DFCC_Colombo_Main", child: Text("Colombo Main - Galle Road")),
        const DropdownMenuItem(value: "DFCC_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "DFCC_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "DFCC_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "DFCC_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "DFCC_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "DFCC_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "DFCC_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "DFCC_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "DFCC_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "DFCC_Jaffna_Main", child: Text("Jaffna Main")),
      ];
      
    case "NDB": // National Development Bank
      return [
        const DropdownMenuItem(value: "NDB_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "NDB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "NDB_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "NDB_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "NDB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "NDB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "NDB_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "NDB_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "NDB_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "NDB_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "NDB_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "NDB_Batticaloa_Main", child: Text("Batticaloa Main")),
      ];
      
    case "AMANA": // Amana Bank
      return [
        const DropdownMenuItem(value: "AMANA_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "AMANA_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "AMANA_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "AMANA_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "AMANA_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "AMANA_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "AMANA_Matale_Main", child: Text("Matale Main")),
        const DropdownMenuItem(value: "AMANA_Mawanella_Main", child: Text("Mawanella Main")),
        const DropdownMenuItem(value: "AMANA_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "AMANA_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "AMANA_Jaffna_Main", child: Text("Jaffna Main")),
        const DropdownMenuItem(value: "AMANA_Batticaloa_Main", child: Text("Batticaloa Main")),
      ];
      
    case "CARGILLS": // Cargills Bank
      return [
        const DropdownMenuItem(value: "CARGILLS_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "CARGILLS_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "CARGILLS_Colombo_Pettah", child: Text("Colombo Pettah")),
        const DropdownMenuItem(value: "CARGILLS_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "CARGILLS_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "CARGILLS_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "CARGILLS_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "CARGILLS_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "CARGILLS_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "CARGILLS_Jaffna_Main", child: Text("Jaffna Main")),
      ];
      
    case "NTB": // Nations Trust Bank
      return [
        const DropdownMenuItem(value: "NTB_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "NTB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "NTB_Colombo_Bambalapitiya", child: Text("Bambalapitiya")),
        const DropdownMenuItem(value: "NTB_Colombo_Dehiwala", child: Text("Dehiwala")),
        const DropdownMenuItem(value: "NTB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "NTB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "NTB_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "NTB_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "NTB_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "NTB_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "NTB_Jaffna_Main", child: Text("Jaffna Main")),
      ];
      
    case "UNION": // Union Bank
      return [
        const DropdownMenuItem(value: "UNION_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "UNION_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "UNION_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "UNION_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "UNION_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "UNION_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "UNION_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "UNION_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "UNION_Jaffna_Main", child: Text("Jaffna Main")),
      ];
      
    case "PAN_ASIA": // Pan Asia Bank
      return [
        const DropdownMenuItem(value: "PAN_ASIA_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "PAN_ASIA_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Matara_Main", child: Text("Matara Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Negombo_Main", child: Text("Negombo Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Kurunegala_Main", child: Text("Kurunegala Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Anuradhapura_Main", child: Text("Anuradhapura Main")),
        const DropdownMenuItem(value: "PAN_ASIA_Jaffna_Main", child: Text("Jaffna Main")),
      ];
      
    case "HABIB": // Habib Bank Limited
      return [
        const DropdownMenuItem(value: "HABIB_Colombo_Main", child: Text("Colombo Main - 2nd Cross Street")),
        const DropdownMenuItem(value: "HABIB_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "HABIB_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "HABIB_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "HABIB_Negombo_Main", child: Text("Negombo Main")),
      ];
      
    case "DEUTSCHE": // Deutsche Bank
      return [
        const DropdownMenuItem(value: "DEUTSCHE_Colombo_Main", child: Text("Colombo Main - Galle Road")),
        const DropdownMenuItem(value: "DEUTSCHE_Colombo_Fort", child: Text("Colombo Fort")),
      ];
      
    case "CITIBANK": // Citibank
      return [
        const DropdownMenuItem(value: "CITIBANK_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "CITIBANK_Colombo_Fort", child: Text("Colombo Fort")),
      ];
      
    case "STANDARD_CHARTERED": // Standard Chartered Bank
      return [
        const DropdownMenuItem(value: "SC_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "SC_Colombo_Fort", child: Text("Colombo Fort")),
        const DropdownMenuItem(value: "SC_Kandy_Main", child: Text("Kandy Main")),
        const DropdownMenuItem(value: "SC_Galle_Main", child: Text("Galle Main")),
        const DropdownMenuItem(value: "SC_Negombo_Main", child: Text("Negombo Main")),
      ];
      
    case "HSBC": // HSBC Bank
      return [
        const DropdownMenuItem(value: "HSBC_Colombo_Main", child: Text("Colombo Main")),
        const DropdownMenuItem(value: "HSBC_Colombo_Fort", child: Text("Colombo Fort")),
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
         padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        backgroundColor: isUploaded ? Colors.green : const Color(0xFF4A0072),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        //padding: const EdgeInsets.symmetric(vertical: 12),
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
              decoration: _inputDecoration("Owner Name", icon: Icons.person),
              validator: (value) => _validateRequired(value, "owner name"),
              textAlign: TextAlign.center,
            ),
            _buildFieldLabel("Owner Email *"),
            TextFormField(
              controller: _ownerEmailController,
              decoration: _inputDecoration("Owner Email", icon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              textAlign: TextAlign.center,
            ),
            _buildFieldLabel("Owner Password *"),
            TextFormField(
              controller: _ownerPasswordController,
              decoration: _inputDecoration("Owner Password", icon: Icons.lock),
              obscureText: true,
              validator: (value) => _validateRequired(value, "owner password"),
              textAlign: TextAlign.center,
            ),
            // _buildFieldLabel("Manager Name *"),
            // TextFormField(
            //   controller: _managerNameController,
            //   decoration: _inputDecoration("Manager Name", icon: Icons.person),
            //   validator: (value) => _validateRequired(value, "manager name"),
            //   textAlign: TextAlign.center,
            // ),
            // _buildFieldLabel("Manager Email *"),
            // TextFormField(
            //   controller: _managerEmailController,
            //   decoration: _inputDecoration("Manager Email", icon: Icons.email),
            //   keyboardType: TextInputType.emailAddress,
            //   validator: _validateEmail,
            //   textAlign: TextAlign.center,
            // ),
            // _buildFieldLabel("Manager Password *"),
            // TextFormField(
            //   controller: _managerPasswordController,
            //   decoration: _inputDecoration(
            //     "Manager Password",
            //     icon: Icons.lock,
            //   ),
            //   obscureText: true,
            //   validator: (value) => _validateRequired(value, "manager password"),
            //   textAlign: TextAlign.center,
            // ),
            // _buildFieldLabel("Manager Phone Number *"),
            // Container(
            //   decoration: _fieldDecoration(),
            //   padding: const EdgeInsets.symmetric(horizontal: 12),
            //   child: IntlPhoneField(
            //     decoration: const InputDecoration(
            //       hintText: 'Manager Phone Number',
            //       border: InputBorder.none,
            //       errorBorder: InputBorder.none,
            //       filled: true,
            //       fillColor: Color(0xFFF3E5F5),
            //     ),
            //     initialCountryCode: 'LK',
            //     onChanged: (phone) => _managerPhoneNumber = phone.completeNumber,
            //     validator: (p) => _validatePhoneNumber(p?.number),
                
            //   ),
            // ),
            const SizedBox(height: 30),
            Container(
            decoration: _fieldDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Set opening hours and date',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold,
                      color: Colors.black,
                      ),
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color(00000000),
                      
                    ),
                    enabled: false,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6A1B9A), width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black, // Set black background
                        borderRadius: BorderRadius.circular(5),
                      ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SaloonOpeningHoursScreen(openingHours: {},),
                        ),
                      );
                    },
                  ),
                ),
                ),
              ],
            ),
          ),
            
            const SizedBox(height: 20),
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
GestureDetector(
  onTap: _showTermsAndConditions,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children:  [
      Text(
        "View agreement Template",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(width: 6),
      Icon(Icons.remove_red_eye,
      color: _hasAgreed ? Colors.green : Colors.black,
      ),
    ],
  ),
),


          const SizedBox(height: 10),
          Center(child: _buildFieldLabel("Business Registration *")),
          Center(
            child: _purpleUploadButton(
              "Upload",
              isUploaded: _businessRegUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "business_reg",
                  userId: _emailController.text.trim(),
                );
                if (url != null) {
                  setState(() {
                    _businessRegUploaded = true;
                    _businessRegImageUrl = url;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Business registration image uploaded successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to upload business registration image."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Tax Registered',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text("Yes"),
                          Checkbox(
                            value: _isTaxRegisteredYes,
                            onChanged: (value) {
                              setState(() {
                                _isTaxRegisteredYes = true;
                                _isTaxRegisteredNo = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          const Text("No"),
                          Checkbox(
                            value: _isTaxRegisteredNo,
                            onChanged: (value) {
                              setState(() {
                                _isTaxRegisteredYes = false;
                                _isTaxRegisteredNo = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ), 
          Center(child: _buildFieldLabel("Outlet Logo*")),
          Center(
            child: _purpleUploadButton(
              "Upload",
              isUploaded: _logoUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "logo",
                  userId: _emailController.text.trim(),
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
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "National Identification",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Center(child: _buildFieldLabel("NIC Front Image *")),
          Center(
            child: _purpleUploadButton(
              "Upload",
              isUploaded: _nicFrontUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "nic_front",
                  userId: _emailController.text.trim(),
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
          ),
          Center(child: _buildFieldLabel("NIC Back Image *")),
          Center(
            child: _purpleUploadButton(
              "Upload",
              isUploaded: _nicBackUploaded,
              onPressed: () async {
                final url = await uploadFileToFirebase(
                  fileType: "nic_back",
                  userId: _emailController.text.trim(),
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
          ),
          
          const SizedBox(height: 20),
          Center(
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Color(0xFF6A1B9A))
                : ElevatedButton(
                    onPressed: () {
                        if (!_hasAgreed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must accept the Terms and Conditions to continue.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                       next();
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
              validator: (value) => _validateRequired(value, "beneficiary name"),
              textAlign: TextAlign.center,
            ),
            _buildFieldLabel("Account Number *"),
            TextFormField(
              controller: _accountNumberController,
              decoration: _inputDecoration("Account Number"),
              keyboardType: TextInputType.number,
              validator: (value) => _validateRequired(value, "account number"),
              textAlign: TextAlign.center,
            ),
            _buildFieldLabel("Bank Name *"),
            DropdownButtonFormField<String>(
              value: _selectedBank,
              items: const [
                DropdownMenuItem(value: "BOC", child: Text("Bank of Ceylon")),
                DropdownMenuItem(value: "PB", child: Text("Peoples Bank")),
                DropdownMenuItem(value: "HNB", child: Text("Hatton National Bank")),
                DropdownMenuItem(value: "COMB", child: Text("Commercial Bank")),
                DropdownMenuItem(value: "SB", child: Text("Seylan Bank")),
                DropdownMenuItem(value: "SAMPATH", child: Text("Sampath Bank")),
                DropdownMenuItem(value: "DFCC", child: Text("DFCC Bank")),
                DropdownMenuItem(value: "NDB", child: Text("National Development Bank")),
                DropdownMenuItem(value: "AMANA", child: Text("Amana Bank")),
                DropdownMenuItem(value: "CARGILLS", child: Text("Cargills Bank")),
                DropdownMenuItem(value: "NTB", child: Text("National Trust Bank")),
                DropdownMenuItem(value: "UNION", child: Text("Union Bank")),
                DropdownMenuItem(value: "PAN_aSIA", child: Text("Pan Asia Bank")),
                DropdownMenuItem(value: "HABIB", child: Text("Habib Bank")),
                DropdownMenuItem(value: "DEUTSCHE", child: Text("Deutsche Bank")),
                DropdownMenuItem(value: "CITIBANK", child: Text("Citi Bank")),
                DropdownMenuItem(value: "STANDARD_CHARTERED", child: Text("Standard Chartered Bank")),
                DropdownMenuItem(value: "HSBC", child: Text("HSBC Bank")),


              ],
              onChanged: (value) {
                setState(() {
                  _selectedBank = value;
                  _selectedBranch = null;
                });
              },
              decoration: _inputDecoration("Select Bank"),
              validator: (value) => value == null || value.isEmpty ? "Please select a bank" : null,
              style: const TextStyle(
                    color: Colors.black, // Text color for selected item
                    fontSize: 16,
                  ),
                  alignment: Alignment.center, // Center the selected item
                  itemHeight: 50, // Optional: Adjust item height for better appearance
                  dropdownColor: const Color(0xFFF3E5F5), // Match your theme

            ),
            
            _buildFieldLabel("Bank Branch *"),
            DropdownButtonFormField<String>(
              value: _selectedBranch,
              //isExpanded: true,
              items: _getBranchOptions(),
              onChanged: (value) {
                setState(() {
                  _selectedBranch = value;
                });
              },
              decoration: _inputDecoration("Select Branch"),
              validator: (value) => value == null || value.isEmpty ? "Please select a branch" : null,
              style: const TextStyle(
                    color: Colors.black, // Text color for selected item
                    fontSize: 16,
                  ),
                  alignment: Alignment.center, // Center the selected item
                  itemHeight: 50, // Optional: Adjust item height for better appearance
                  dropdownColor: const Color(0xFFF3E5F5), // Match your theme

            ),
            // _buildFieldLabel("Bank Phone Number *"),
            // Container(
            //   decoration: _fieldDecoration(),
            //   padding: const EdgeInsets.symmetric(horizontal: 12),
            //   child: IntlPhoneField(
            //     decoration: const InputDecoration(
            //       hintText: 'Bank Phone Number',
            //       border: InputBorder.none,
            //       errorBorder: InputBorder.none,
            //       filled: true,
            //       fillColor: Color(0xFFF3E5F5),
            //     ),
            //     initialCountryCode: 'LK',
            //     onChanged: (phone) => _bankPhoneNumber = phone.completeNumber,
            //     validator: (p) => _validatePhoneNumber(p?.number),
            //   ),
            // ),
            const SizedBox(height: 20),
            Center(child: _buildFieldLabel("Soft Copy of the Bank Statement Or\n Passbook *",
            
            )),
            Center(
              child: _purpleUploadButton(
                "Upload",
                isUploaded: _bankStatementUploaded,
                onPressed: () async {
                  final url = await uploadFileToFirebase(
                    fileType: "bank_statement",
                    userId: _emailController.text.trim(),
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
            ),
const SizedBox(height: 30),
Center(
            child: _isSubmitting
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
                        horizontal: 80,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Finish",
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
