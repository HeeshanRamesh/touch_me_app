import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:touch_me/merchant_services_screen.dart';
import 'login_page.dart';
import '../models/service.dart';

class AddServiceScreen extends StatefulWidget {
  final Service? service; // Pass service for edit mode
  final String? serviceId; // Pass ID for edit mode
  final String? merchantId; // Pass merchantId for add mode

  const AddServiceScreen({
    Key? key,
    this.service,
    this.serviceId,
    this.merchantId, // Pass merchantId here for ADD mode
  }) : super(key: key);

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  bool _isSubmitting = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _serviceNameController.text = widget.service!.serviceName;
      _descriptionController.text = widget.service!.serviceDescription;
      _priceController.text = widget.service!.price.toString();
      _imageUrl = widget.service!.image;
    } else {
      _imageUrl = 'https://example.com/images/massage.jpg';
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final response = await _sendServiceToBackend();

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
          // Navigate to MerchantServicesScreen after success!
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      MerchantServicesScreen(merchantId: widget.merchantId!),
            ),
            (Route<dynamic> route) => false,
          );
        } else if (response.statusCode == 401) {
          await storage.delete(key: "token");
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


  Future<http.Response> _sendServiceToBackend() async {
    const String baseUrl = 'http://192.168.8.199:6000';
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
      if (price <= 0)
        throw const FormatException("Price must be greater than 0");
    } catch (e) {
      throw const FormatException("Invalid price format");
    }

    final Map<String, dynamic> serviceData = {
      "serviceName": _serviceNameController.text.trim(),
      "serviceDescription": _descriptionController.text.trim(),
      "price": price,
      "image": _imageUrl,
      "isActive": true,
    };

    if (widget.serviceId != null) {
      // Editing existing service
      endpoint = '/api/services/${widget.serviceId}';
      method = 'PUT';
    } else {
      // Adding for a specific merchant
      if (widget.merchantId == null || widget.merchantId!.isEmpty) {
        throw Exception("Merchant ID not provided for adding a service.");
      }
      endpoint = '/api/services/${widget.merchantId}';
      method = 'POST';
    }

    final url = Uri.parse('$baseUrl$endpoint');

    const retryOptions = RetryOptions(
      maxAttempts: 3,
      delayFactor: Duration(seconds: 1),
    );

    Future<http.Response> request() {
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
            .timeout(const Duration(seconds: 5));
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
            .timeout(const Duration(seconds: 5));
      }
    }

    final response = await retry(
      () => request(),
      retryIf: (e) => e is http.ClientException || e is TimeoutException,
      onRetry: (e) => print('Retrying $method due to: $e'),
    );

    print(
      'Service Response: Status=${response.statusCode}, Body=${response.body}',
    );
    return response;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          _imageUrl = 'https://example.com/images/uploaded.jpg';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image selected (mock upload).")),
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
              _buildInputField("Service Name", _serviceNameController),
              _buildInputField(
                "Description",
                _descriptionController,
                maxLines: 3,
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
                  if (value == null || value.trim().isEmpty)
                    return 'Please enter price';
                  try {
                    final price = double.parse(value.trim());
                    if (price <= 0) return 'Price must be greater than 0';
                    return null;
                  } catch (e) {
                    return 'Please enter a valid number (e.g., 1500 or 1500.00)';
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text(
                  "Pick Image (Optional)",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSubmitting ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
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
        validator:
            validator ??
            (value) =>
                value == null || value.trim().isEmpty
                    ? 'Please enter $hint'
                    : null,
        decoration: InputDecoration(
          hintText: hint,
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
