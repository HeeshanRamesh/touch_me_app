import 'package:flutter/material.dart';
import 'package:touch_me/merchant_service_list_screen.dart';
import '../models/service.dart';
import '../models/merchant.dart';
import '../services/services.dart';
import '../services/merchant_service.dart';

class MerchantListScreen extends StatefulWidget {
  final String serviceName;
  final String token;
  final String customerId;

  const MerchantListScreen({
    super.key,
    required this.serviceName,
    required this.token,
    required this.customerId,
  });

  @override
  State<MerchantListScreen> createState() => _MerchantListScreenState();
}

class _MerchantListScreenState extends State<MerchantListScreen> {
  List<Merchant> merchants = [];
  Map<String, List<Service>> merchantServices = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadMerchantsAndServices();
  }

  Future<void> loadMerchantsAndServices() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // First, get all merchants
      final fetchedMerchants = await fetchMerchants(widget.token);
      
      // Then, for each merchant, get their services filtered by category
      Map<String, List<Service>> servicesMap = {};
      
      for (final merchant in fetchedMerchants) {
        try {
          final services = await fetchServicesByMerchantAndCategory(
            merchant.id,
            widget.serviceName,
            widget.token,
          );
          if (services.isNotEmpty) {
            servicesMap[merchant.id] = services;
          }
        } catch (e) {
          print('Error fetching services for merchant ${merchant.id}: $e');
        }
      }

      // Only show merchants that have services matching the selected category
      final merchantsWithServices = fetchedMerchants.where((merchant) {
        return servicesMap.containsKey(merchant.id) && 
               servicesMap[merchant.id]!.isNotEmpty;
      }).toList();

      setState(() {
        merchants = merchantsWithServices;
        merchantServices = servicesMap;
        isLoading = false;
      });

      if (merchantsWithServices.isEmpty) {
        print('ℹ️ No merchants found with services for category: ${widget.serviceName}');
      }

    } catch (e) {
      print('❌ Error loading merchants and services: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load services'),
                    ],
                  ),
                )
              : merchants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No merchants found for\n"${widget.serviceName}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadMerchantsAndServices,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: merchants.length,
                        itemBuilder: (context, index) {
                          final merchant = merchants[index];
                          final services = merchantServices[merchant.id] ?? [];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Merchant Info
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: AssetImage(
                                          'assets/saloonservice.jpg', // Default image
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              merchant.outletName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              merchant.address,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  merchant.rating?.toString() ?? '5.0',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${merchant.reviews ?? 0} reviews',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Services
                                  Text(
                                    'Available ${widget.serviceName} Services:',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  ...services.map((service) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.serviceName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (service.duration?.isNotEmpty == true)
                                                Text(
                                                  service.duration!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'LKR ${service.price}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6A1B9A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Book Now Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MerchantServiceListScreen(
        merchantId: merchant.id,
        outletName: merchant.outletName,
        token: widget.token,
        customerId: widget.customerId,
        profileImageUrl: merchant.logoUrl, // make sure `logoUrl` exists
      ),
    ),
  );
},

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6A1B9A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        'Visit Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}