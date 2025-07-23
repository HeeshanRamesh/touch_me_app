import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:touch_me/merchant_services_screen.dart';
import 'login_page.dart';
import '../models/service.dart';

class AddServiceScreen extends StatefulWidget {
  final Service? service;
  final String? serviceId;
  final String? merchantId;

  const AddServiceScreen({
    super.key,
    this.service,
    this.serviceId,
    this.merchantId,
  });

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  String? _imageUrl;
  File? _selectedImage;
  
  String? _selectedServiceCategory;
  bool _isCustomService = false;
  
  final List<String> _serviceCategories = [
    'Haircut & Styling - Ladies',
    'Haircut & Styling - Gents',
    'Haircut & Styling - Kids',
    'Haircut & Styling - Adults',
    'Massage',
    'Bridal',
    'Tattoo & Piercing',
    'Facials & Skincare',
    'Hair Removal',
    'Nails',
    'Eyebrow & EyeLashes',
    'Injectable & Fillers',
    'Makeup',
    'Dressing',
    'Pedicure & Manicure',
    'Door Step Service',
    'Custom Service',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      String serviceName = widget.service!.serviceName;
      if (_serviceCategories.contains(serviceName)) {
        _selectedServiceCategory = serviceName;
        _isCustomService = false;
      } else {
        _selectedServiceCategory = 'Custom Service';
        _isCustomService = true;
        _serviceNameController.text = serviceName;
      }
      
      _descriptionController.text = widget.service!.serviceDescription;
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.duration ?? '';
      _imageUrl = widget.service!.image;
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _onServiceCategoryChanged(String? value) {
    setState(() {
      _selectedServiceCategory = value;
      if (value == 'Custom Service') {
        _isCustomService = true;
        _serviceNameController.clear();
      } else {
        _isCustomService = false;
        _serviceNameController.text = value ?? '';
      }
    });
  }

  String _getCurrentServiceName() {
    if (_isCustomService) {
      return _serviceNameController.text.trim();
    } else {
      return _selectedServiceCategory ?? '';
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      setState(() => _isUploadingImage = true);

      String fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('service_images')
          .child(fileName);

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully! Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to upload image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        String? uploadedImageUrl = _imageUrl;

        if (_selectedImage != null) {
          uploadedImageUrl = await _uploadImageToFirebase(_selectedImage!);
          if (uploadedImageUrl == null) {
            return;
          }
        }

        final response = await _sendServiceToBackend(uploadedImageUrl);

        if (!mounted) return;

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.serviceId != null
                    ? "Service updated successfully!"
                    : "Service added successfully!",
              ),
              backgroundColor: Colors.green,
            ),
          );

          String? merchantId = widget.merchantId;
          if (merchantId == null || merchantId.isEmpty) {
            merchantId = await storage.read(key: "merchantId");
          }

          if (merchantId != null && merchantId.isNotEmpty) {
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        } else if (response.statusCode == 401) {
          await storage.delete(key: "token");
          await storage.delete(key: "merchantId");
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Session expired. Please log in again."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          final responseBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to ${widget.serviceId != null ? 'update' : 'add'} service: ${responseBody['error']?['message'] ?? response.reasonPhrase}",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        String errorMessage = "An error occurred";
        if (e.toString().contains("Connection refused")) {
          errorMessage =
              "Cannot connect to the server. Please check if the server is running and the URL is correct.";
        } else if (e is FormatException) {
          errorMessage = e.toString();
        } else {
          errorMessage = "Error: $e";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  Future<http.Response> _sendServiceToBackend(String? imageUrl) async {
    const String baseUrl = 'http://api.touchmeapp.com';
    String endpoint = '';
    String method = 'POST';

    String? token = await storage.read(key: "token");
    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found. Please log in again.");
    }

    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) throw const FormatException("Price cannot be empty");
    double price;
    try {
      price = double.parse(priceText);
      if (price <= 0) {
        throw const FormatException("Price must be greater than 0");
      }
    } catch (e) {
      throw const FormatException("Invalid price format");
    }

    final durationText = _durationController.text.trim();
    if (durationText.isEmpty)
      throw const FormatException("Duration cannot be empty");
    final durationRegex = RegExp(r'^\d+hour:\d+minutes:\d+seconds$');
    if (!durationRegex.hasMatch(durationText)) {
      throw const FormatException(
        "Invalid duration format. Use Xhour:Yminutes:Zseconds (e.g., 1hour:30minutes:0seconds)",
      );
    }

    if (widget.serviceId != null) {
      endpoint = '/api/services/${widget.serviceId}';
      method = 'PUT';
    } else {
      String? merchantId = widget.merchantId;
      if (merchantId == null || merchantId.isEmpty) {
        merchantId = await storage.read(key: "merchantId");
      }
      if (merchantId == null || merchantId.isEmpty) {
        throw Exception("Merchant ID not found. Please log in again.");
      }
      endpoint = '/api/services/$merchantId';
      method = 'POST';
    }

    final url = Uri.parse('$baseUrl$endpoint');

    const retryOptions = RetryOptions(
      maxAttempts: 3,
      delayFactor: Duration(seconds: 1),
    );

    String currentServiceName = _getCurrentServiceName();
    if (currentServiceName.isEmpty) {
      throw const FormatException("Please select or enter a service name");
    }

    final Map<String, dynamic> serviceData = {
      "serviceName": currentServiceName,
      "serviceDescription": _descriptionController.text.trim(),
      "price": price,
      "duration": durationText,
      "isActive": true,
      "image": imageUrl,
    };

    if (imageUrl != null && imageUrl.isNotEmpty) {
      serviceData["image"] = imageUrl;
      print('Sending image URL to backend: $imageUrl');
    }

    Future<http.Response> request() async {
      if (method == 'PUT') {
        return http
            .put(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(serviceData),
            )
            .timeout(const Duration(seconds: 30));
      } else {
        return http
            .post(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(serviceData),
            )
            .timeout(const Duration(seconds: 30));
      }
    }

    final response = await retry(
      () => request(),
      retryIf: (e) => e is http.ClientException || e is TimeoutException,
      onRetry: (e) => print('Retrying $method due to: $e'),
    );

    return response;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Image selected successfully. It will be uploaded when you submit.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to pick image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.serviceId != null ? "Edit Service" : "Add Service",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.serviceId != null ? "Edit Service" : "Service Details",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildServiceCategoryDropdown(),
              
              if (_isCustomService) _buildCustomServiceNameField(),
              
              _buildInputField(
                "Description",
                _descriptionController,
                maxLines: 3,
                validator: null,
              ),
              _buildInputField(
                "Price (LKR)",
                _priceController,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*(\.\d{0,2})?$'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  try {
                    final price = double.parse(value.trim());
                    if (price <= 0) return 'Price must be greater than 0';
                    return null;
                  } catch (e) {
                    return 'Please enter a valid number (e.g., 1500 or 1500.00)';
                  }
                },
              ),
              _buildInputField(
                "Duration (e.g., 1hour:30minutes:0seconds)",
                _durationController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter duration';
                  }
                  final durationRegex = RegExp(r'^\d+hour:\d+minutes:\d+seconds$');
                  if (!durationRegex.hasMatch(value.trim())) {
                    return 'Please enter duration in Xhour:Yminutes:Zseconds format (e.g., 1hour:30minutes:0seconds)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildImageSection(),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed:
                    (_isSubmitting || _isUploadingImage) ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    (_isSubmitting || _isUploadingImage)
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isUploadingImage
                                  ? "Uploading Image..."
                                  : "Saving...",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                        : Text(
                          widget.serviceId != null
                              ? "Update Service"
                              : "Add Service",
                          style: const TextStyle(color: Colors.white),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedServiceCategory,
        decoration: InputDecoration(
          labelText: widget.serviceId != null ? "Service Category" : null,
          hintText: widget.serviceId != null ? null : "Select Service Category",
          floatingLabelBehavior:
              widget.serviceId != null
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.never,
          labelStyle: const TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFB39DDB),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.4),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.4),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        items: _serviceCategories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: _onServiceCategoryChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a service category';
          }
          return null;
        },
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF6A1B9A),
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildCustomServiceNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _serviceNameController,
        decoration: InputDecoration(
          labelText: widget.serviceId != null ? "Custom Service Name" : null,
          hintText: widget.serviceId != null ? null : "Enter custom service name",
          floatingLabelBehavior:
              widget.serviceId != null
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.never,
          labelStyle: const TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFB39DDB),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.4),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.4),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) {
          if (_isCustomService && (value == null || value.trim().isEmpty)) {
            return 'Please enter a custom service name';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Service Image",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 8),

        if (_selectedImage != null)
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6A1B9A), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _isUploadingImage ? null : _pickImage,
                    icon: const Icon(Icons.refresh, color: Color(0xFF6A1B9A)),
                    label: const Text(
                      "Change Image",
                      style: TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed:
                        _isUploadingImage
                            ? null
                            : () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Remove",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          )
        else if (_imageUrl != null && _imageUrl!.isNotEmpty)
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6A1B9A), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _isUploadingImage ? null : _pickImage,
                icon: const Icon(Icons.refresh, color: Color(0xFF6A1B9A)),
                label: const Text(
                  "Change Image",
                  style: TextStyle(color: Color(0xFF6A1B9A)),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: _isUploadingImage ? null : _pickImage,
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            label: const Text(
              "Upload Image (Optional)",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B9A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 69),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText:
              widget.serviceId != null
                  ? hint
                  : null,
          hintText:
              widget.serviceId != null
                  ? null
                  : hint,
          floatingLabelBehavior:
              widget.serviceId != null
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.never,
          labelStyle: const TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFB39DDB),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 1.4),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.4),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}