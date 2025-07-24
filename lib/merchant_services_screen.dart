import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/add_services_screen.dart';
import '../models/service.dart';

class MerchantServicesScreen extends StatefulWidget {
  const MerchantServicesScreen({super.key, required String merchantId});

  @override
  State<MerchantServicesScreen> createState() => _MerchantServicesScreenState();
}

class _MerchantServicesScreenState extends State<MerchantServicesScreen> {
  final storage = const FlutterSecureStorage();
  List<Service> _services = [];
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    fetchMerchantServices();
  }

  Future<void> fetchMerchantServices() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    try {
      final String? token = await storage.read(key: "token");
      final String? merchantId = await storage.read(key: "merchantId");
      if (token == null || merchantId == null) {
        throw Exception("Not logged in or merchantId not found.");
      }

      final url = Uri.parse(
        'http://api.touchmeapp.com/api/services/merchant/$merchantId',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _services =
              (data as List).map((json) => Service.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      final String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Not logged in.");
      }
      final url = Uri.parse(
        'http://api.touchmeapp.com/api/services/$serviceId',
      );
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _services.removeWhere((s) => s.id == serviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Service deleted."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error']?['message'] ?? 'Failed to delete'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void confirmDelete(Service service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete "${service.serviceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteService(service.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void goToEdit(Service service) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddServiceScreen(
          service: service,
          serviceId: service.id,
          merchantId: null, // Editing: don't need merchantId param
        ),
      ),
    );
    fetchMerchantServices(); // Refresh list after editing
  }

  void goToAdd() async {
    final String? merchantId = await storage.read(key: "merchantId");
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddServiceScreen(merchantId: merchantId),
      ),
    );
    fetchMerchantServices(); // Refresh list after adding
  }

  // Helper method to check if image is base64
  bool _isBase64Image(String imageString) {
    return imageString.startsWith('data:image/') || 
           (imageString.length > 50 && !imageString.startsWith('http'));
  }

  // Helper method to decode base64 image
  Uint8List? _decodeBase64Image(String base64String) {
    try {
      // Remove data URL prefix if present
      if (base64String.startsWith('data:image/')) {
        base64String = base64String.split(',')[1];
      }
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  // Helper method to build image widget
  Widget _buildImageWidget(String imageString, {double size = 56}) {
    if (imageString.isEmpty) {
      return Icon(
        Icons.design_services,
        size: size * 0.7,
        color: const Color(0xFF6A1B9A),
      );
    }

    if (_isBase64Image(imageString)) {
      final imageBytes = _decodeBase64Image(imageString);
      if (imageBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.image_not_supported,
              size: size * 0.7,
            ),
          ),
        );
      }
    } else {
      // Regular network image
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageString,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.image_not_supported,
            size: size * 0.7,
          ),
        ),
      );
    }

    // Fallback if image can't be loaded
    return Icon(
      Icons.image_not_supported,
      size: size * 0.7,
    );
  }

  // Show service details dialog
  void showServiceDetails(Service service) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image and close button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageWidget(service.image, size: 80),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.serviceName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "LKR ${service.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (service.specialOffer?.isNotEmpty == true) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "SPECIAL OFFER",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Service details
              if (service.specialOffer?.isNotEmpty == true) ...[
                const Text(
                  "Special Offer",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.specialOffer!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              if (service.serviceDescription?.isNotEmpty == true) ...[
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.serviceDescription!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              
              if (service.duration?.isNotEmpty == true) ...[
                const Text(
                  "Duration",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.duration!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
              ],
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      goToEdit(service);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      confirmDelete(service);
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Services',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? const Center(child: Text("Failed to load services"))
              : _services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.design_services_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No services found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: goToAdd,
                            child: const Text("Add Service"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => showServiceDetails(service),
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  _buildImageWidget(service.image, size: 50),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.serviceName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "LKR ${service.price.toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                color: Color(0xFF6A1B9A),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (service.specialOffer?.isNotEmpty == true) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  "OFFER",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}