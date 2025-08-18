import 'package:flutter/material.dart';
import 'package:touch_me/pages/merchant_service_list_screen.dart';
import '../models/service.dart';
import '../models/merchant.dart';
import '../models/review.dart';
import '../services/services.dart';
import '../services/merchant_service.dart';
import '../services/reviews.dart';

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
  Map<String, Map<String, dynamic>> _merchantRatings = {}; // Cache for ratings
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

  // Helper method to calculate review statistics
  Map<String, dynamic> _calculateReviewStats(List<Review> reviews) {
    if (reviews.isEmpty) {
      return {"average": 0.0, "count": 0};
    }

    double totalRating = 0.0;
    int validReviews = 0;

    for (final review in reviews) {
      if (review.rating > 0 && review.rating <= 5) {
        totalRating += review.rating;
        validReviews++;
      }
    }

    double averageRating = validReviews > 0 ? totalRating / validReviews : 0.0;

    return {"average": averageRating, "count": validReviews};
  }

  // Method to fetch and cache ratings for a merchant
  Future<Map<String, dynamic>> _getMerchantRating(String merchantId) async {
    if (_merchantRatings.containsKey(merchantId)) {
      return _merchantRatings[merchantId]!;
    }

    try {
      final reviews = await fetchReviewsByMerchant(merchantId, widget.token);
      final stats = _calculateReviewStats(reviews);
      _merchantRatings[merchantId] = stats;
      return stats;
    } catch (e) {
      print('DEBUG: Error fetching reviews for merchant $merchantId: $e');
      final defaultStats = {"average": 0.0, "count": 0};
      _merchantRatings[merchantId] = defaultStats;
      return defaultStats;
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
                                        backgroundImage: merchant.logoUrl.isNotEmpty
                                            ? NetworkImage(merchant.logoUrl)
                                            : const AssetImage('assets/saloonservice.jpg') as ImageProvider,
                                        backgroundColor: Colors.grey[200],
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
                                            // FIXED: Real-time rating display using FutureBuilder
                                            FutureBuilder<Map<String, dynamic>>(
                                              future: _getMerchantRating(merchant.id),
                                              builder: (context, ratingSnapshot) {
                                                if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                                  return Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 12,
                                                        height: 12,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 1.5,
                                                          color: Colors.amber,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "Loading ratings...",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }

                                                final stats = ratingSnapshot.data ?? {"average": 0.0, "count": 0};
                                                final averageRating = stats["average"] as double;
                                                final reviewCount = stats["count"] as int;

                                                return Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 16,
                                                      color: reviewCount > 0 ? Colors.amber : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      reviewCount > 0 
                                                          ? averageRating.toStringAsFixed(1)
                                                          : 'No rating',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: reviewCount > 0 ? Colors.black87 : Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      reviewCount > 0 
                                                          ? '$reviewCount review${reviewCount != 1 ? 's' : ''}'
                                                          : 'No reviews',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
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
                                                  'Duration: ${service.duration!} minutes',
                                                  style: TextStyle(
                                                    fontSize: 15,
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
                                              profileImageUrl: merchant.logoUrl,
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