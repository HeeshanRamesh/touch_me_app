import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:touch_me/services/nic_validation.dart';

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

  // COMMENTED OUT: Bank account validation
  /*
  String? _validateAccountNumber(String? value) {
    // Debug line - remove after testing
    print("DEBUG: _selectedBank = '$_selectedBank'");
    
    if (value == null || value.trim().isEmpty) {
      return "Please enter an account number";
    }
    
    final cleanedValue = value.trim().replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-digits
    
    // Basic length check
    if (cleanedValue.length < 8) {
      return "Account number must be at least 8 digits";
    }
    
    if (cleanedValue.length > 20) {
      return "Account number cannot exceed 20 digits";
    }
    
    // Bank-specific validation - only if bank is selected
    if (_selectedBank != null && _selectedBank!.isNotEmpty) {
      switch (_selectedBank!) {
        case "BOC": // Bank of Ceylon - typically 10-12 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 12) {
            return "BOC account numbers are typically 10-12 digits";
          }
          break;
          
        case "PB": // People's Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "People's Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "COMB": // Commercial Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Commercial Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "HNB": // Hatton National Bank - typically 12-15 digits
          if (cleanedValue.length < 12 || cleanedValue.length > 15) {
            return "HNB account numbers are typically 12-15 digits";
          }
          break;
          
        case "SAMPATH": // Sampath Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Sampath Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "SB": // Seylan Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Seylan Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "DFCC": // DFCC Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "DFCC Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "NDB": // National Development Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "NDB account numbers are typically 10-15 digits";
          }
          break;
          
        case "AMANA": // Amana Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Amana Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "CARGILLS": // Cargills Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Cargills Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "NTB": // Nations Trust Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "NTB account numbers are typically 10-15 digits";
          }
          break;
          
        case "UNION": // Union Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Union Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "PAN_ASIA": // Pan Asia Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Pan Asia Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "HABIB": // Habib Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Habib Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "DEUTSCHE": // Deutsche Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Deutsche Bank account numbers are typically 10-15 digits";
          }
          break;
          
        case "CITIBANK": // Citibank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Citibank account numbers are typically 10-15 digits";
          }
          break;
          
        case "STANDARD_CHARTERED": // Standard Chartered - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "Standard Chartered account numbers are typically 10-15 digits";
          }
          break;
          
        case "HSBC": // HSBC Bank - typically 10-15 digits
          if (cleanedValue.length < 10 || cleanedValue.length > 15) {
            return "HSBC account numbers are typically 10-15 digits";
          }
          break;
        default:
          // Generic validation for other banks
          if (cleanedValue.length < 8 || cleanedValue.length > 20) {
            return "Account number must be 8-18 digits";
          }
          break;
      }
    }
    
    return null;
  }
  */

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
  
  // COMMENTED OUT: Bank-related controllers
  /*
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  */

  // Form keys for validation
  final GlobalKey<FormState> _outletInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactInfoFormKey = GlobalKey<FormState>();
  // COMMENTED OUT: Bank info form key
  // final GlobalKey<FormState> _bankInfoFormKey = GlobalKey<FormState>();

  // State for uploads and selections
  String? _phoneNumber;
  //String? _managerPhoneNumber;
  //String? _bankPhoneNumber;
  bool _taxRegistered = false;
  bool _nicFrontUploaded = false;
  bool _nicBackUploaded = false;
  bool _businessRegUploaded = false;
  bool _logoUploaded = false;
  // COMMENTED OUT: Bank statement upload
  // bool _bankStatementUploaded = false;
  bool _outletPictureUploaded = false;
  String? _outletPictureUrl;
  
  // COMMENTED OUT: Bank-related variables
  /*
  String? _selectedBank;
  String? _selectedBranch;
  String? _bankStatementImageUrl;
  */
  
  String? _businessRegImageUrl;
  String? _logoImageUrl;
  String? _nicFrontImageUrl;
  String? _nicBackImageUrl;
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
    
    // COMMENTED OUT: Bank controller disposal
    /*
    _beneficiaryNameController.dispose();
    _accountNumberController.dispose();
    */
    
    _controller.dispose();
    NICValidationService.dispose(); 
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
      
      // COMMENTED OUT: Bank info validation (case 3)
      /*
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
      */
    }

    if (!isValid) return;

    // Updated: Only allow navigation to step 2 (index 1)
    if (_page < 2) {
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
      // COMMENTED OUT: Bank info success message
      /*
      case 3:
        return "Bank information saved!";
      */
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

  // COMMENTED OUT: Bank info validation
  /*
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
  */

  Future<void> _submitForm() async {
    // COMMENTED OUT: Bank form validation
    /*
    if (!_bankInfoFormKey.currentState!.validate()) return;
    if (!_validateBankInfoStep()) return;
    */
    
    if (_phoneNumber == null) {
      // _OwnerPhoneNumber == null){
      // _bankPhoneNumber == null) {
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
        
        // COMMENTED OUT: Bank-related parameters
        /*
        beneficiaryName: _beneficiaryNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        //bankPhone: _bankPhoneNumber!,
        bankName: _selectedBank!,
        bankBranch: _selectedBranch!,
        */
        
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
    bool validateNIC = false,
    bool isNICFront = false,
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

      // Read file bytes if not available
      if (fileBytes == null && filePath != null) {
        fileBytes = await File(filePath).readAsBytes();
      }

      // Validate NIC if required
      if (validateNIC && fileBytes != null) {
        if (context.mounted) {
          // Show loading dialog during validation
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Validating NIC image..."),
                ],
              ),
            ),
          );
        }

        try {
          final validationResult = await NICValidationService.validateNICImage(
            imageBytes: fileBytes,
            isFrontSide: isNICFront,
          );

          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading dialog
          }

          if (!validationResult.isValid) {
            if (context.mounted) {
              // Show detailed validation error
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    "Invalid ${isNICFront ? 'NIC Front' : 'NIC Back'} Image",
                    style: const TextStyle(color: Colors.red),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        validationResult.errorMessage ?? 
                        "The uploaded image does not appear to be a valid ${isNICFront ? 'NIC front side' : 'NIC back side'}.",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Confidence: ${validationResult.confidence.toStringAsFixed(1)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (validationResult.foundFeatures.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          "Found features:",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        ...validationResult.foundFeatures.map(
                          (feature) => Text("• $feature", style: const TextStyle(color: Colors.green)),
                        ),
                      ],
                      if (validationResult.missingFeatures.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          "Missing features:",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        ...validationResult.missingFeatures.map(
                          (feature) => Text("• $feature", style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                      const SizedBox(height: 15),
                      Text(
                        "Please upload a clear image of your ${isNICFront ? 'NIC front side' : 'NIC back side'}.",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              );
            }
            return null;
          } else {
            // Show success message for valid NIC
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${isNICFront ? 'NIC Front' : 'NIC Back'} validated successfully! (${validationResult.confidence.toStringAsFixed(1)}% confidence)"
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.of(context).pop(); // Close loading dialog if still open
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error validating NIC: $e"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Continue with upload even if validation fails due to technical error
        }
      }

      // Proceed with Firebase upload
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
                // COMMENTED OUT: Fourth progress step for bank info
                // _progressStep(isActive: _page >= 3),
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
                  // COMMENTED OUT: Bank info step
                  // _buildBankInfoStep(),
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
                "Outlet Information - Step 1 of 3", // Updated step count
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
                "Outlet Full Address",
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
            Text(
              "Need Help with registation?",
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

  // COMMENTED OUT: Branch options method for bank selection
  /*
  List<DropdownMenuItem<String>> _getBranchOptions() {
    if (_selectedBank == null) return [];
    
    switch (_selectedBank) {
      case "BOC": // Bank of Ceylon
        return [
          // ... all branch options commented out
        ];
      // ... other bank cases commented out
      default:
        return [];
    }
  }
  */

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
                "Contact Information - Step 2 of 3", // Updated step count
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
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
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
                              builder: (_) => const SaloonOpeningHoursScreen(openingHours: {}),
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
              "Business Information - Step 3 of 3", // Updated step count
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
              children: [
                Text(
                  "View agreement Template",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.remove_red_eye,
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
                  validateNIC: true,  // Enable NIC validation
                  isNICFront: true,   // Specify this is front side
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
                  validateNIC: true,  // Enable NIC validation
                  isNICFront: false,  // Specify this is back side
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
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          // MOVED: Finish button from bank info step to business info step
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
                      // Call submit form instead of next
                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80, // Wider button for "Finish"
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      "Finish", // Changed from "Continue" to "Finish"
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // COMMENTED OUT: Bank info step completely
  /*
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  LengthLimitingTextInputFormatter(18), // Max 18 digits
                ],
                validator: _validateAccountNumber, // Use the new validator
                textAlign: TextAlign.center,
                onChanged: (value) {
                  // Optional: Real-time validation feedback
                  setState(() {});
                },
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
            const SizedBox(height: 20),
            Center(child: _buildFieldLabel("Soft Copy of the Bank Statement Or\n Passbook *")),
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
  */
}