import 'dart:convert';
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
      builder:
          (_) => AlertDialog(
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
        builder: 
            (_) => AddServiceScreen(
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add, color: Color(0xFF6A1B9A)),
        //     onPressed: goToAdd,
        //     tooltip: "Add Service",
        //   ),
        // ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isError
              ? const Center(child: Text("Failed to load services"))
              : _services.isEmpty
              ? const Center(child: Text("No services found. Tap + to add."))
              : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading:
                          service.image.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  service.image,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        size: 42,
                                      ),
                                ),
                              )
                              : const Icon(
                                Icons.design_services,
                                size: 40,
                                color: Color(0xFF6A1B9A),
                              ),
                      title: Text(
                        service.serviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        service.serviceDescription ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "LKR ${service.price.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF6A1B9A),
                            ),
                            onPressed: () => goToEdit(service),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDelete(service),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
