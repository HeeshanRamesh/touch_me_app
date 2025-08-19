import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:touch_me/pages/merchant_list_screen.dart';
import 'package:touch_me/pages/merchant_service_list_screen.dart';
import 'package:touch_me/pages/service_filter_page.dart';
import '../models/merchant.dart';
import '../models/review.dart';
import '../services/merchant_service.dart';
import '../services/reviews.dart';

class CustomerHomeHeader extends StatelessWidget {
  final String userName;
  final String location;
  final String token;

  const CustomerHomeHeader({
    super.key,
    required this.userName,
    required this.location,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9D1E96), Color(0xFF7E1878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: Image.asset(
                    'assets/touch_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF6A1B9A),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              readOnly: false,
              decoration: const InputDecoration(
                hintText: "Search Your Service",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 24,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onTap: () {
                // Open search screen if needed
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerHomeContent extends StatefulWidget {
  final String token;
  final String customerId;
  final Map<String, dynamic> user;

  const CustomerHomeContent({
    super.key,
    required this.token,
    required this.customerId,
    required this.user,
  });

  @override
  State<CustomerHomeContent> createState() => _CustomerHomeContentState();
}

class _CustomerHomeContentState extends State<CustomerHomeContent> {
  Position? _userPosition;
  Map<String, Map<String, dynamic>> _merchantRatings = {};

  double getDistanceFromUser(Position userPos, Merchant merchant) {
    return Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      merchant.latitude,
      merchant.longitude,
    );
  }

  String _currentLocation = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = "Location off";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = "Permission denied";
      });
      return;
    }

    _userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (_userPosition != null) {
      final placemarks = await placemarkFromCoordinates(
        _userPosition!.latitude,
        _userPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentLocation = place.locality ?? place.subAdministrativeArea ?? "Unknown";
        });
      } else {
        setState(() {
          _currentLocation = "Unknown";
        });
      }
    }
  }

  Future<List<Merchant>> fetchNearestMerchants() async {
    final allMerchants = await fetchMerchants(widget.token);

    if (_userPosition == null) return [];

    final nearestMerchants = allMerchants.where((merchant) {
      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        merchant.latitude,
        merchant.longitude,
      );
      return distance <= 10000;
    }).toList();

    nearestMerchants.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        a.latitude,
        a.longitude,
      );
      final distB = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        b.latitude,
        b.longitude,
      );
      return distA.compareTo(distB);
    });

    return nearestMerchants;
  }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;

    final List<Map<String, String>> services = [
      {'name': 'Haircut & Styling - Ladies ', 'image': 'assets/services/haircut_image.png'},
      {'name': 'Haircut & Styling - Gents', 'image': 'assets/services/Ellipse 325.png'},
      {'name': 'Haircut & Styling - Kids', 'image': 'assets/services/kid.png'},
      {'name': 'Haircut & Styling - Adults', 'image': 'assets/services/old.png'},
      {'name': 'Massage', 'image': 'assets/services/massage_image.png'},
      {'name': 'Bridal', 'image': 'assets/services/bridal.png'},
      {'name': 'Tattoo & Piercing', 'image': 'assets/services/tattoo_image.png'},
      {'name': 'Facials & Skincare', 'image': 'assets/services/Ellipse 328.png'},
      {'name': 'Hair Removal', 'image': 'assets/services/hair_removal_image.png'},
      {'name': 'Nails', 'image': 'assets/services/nail_salon_image.png'},
      {'name': 'Eyebrow & EyeLashes', 'image': 'assets/services/brows_lashes_image.png'},
      {'name': 'Injectable & Fillers', 'image': 'assets/services/piercing_image.png'},
      {'name': 'Makeup', 'image': 'assets/services/makeup_image.png'},
      {'name': 'Dressing', 'image': 'assets/services/dress.png'},
      {'name': 'Pedicure & Manicure', 'image': 'assets/services/image.png'},
      {'name': 'Door Step Service', 'image': 'assets/services/home.png'},
    ];

    return Column(
      children: [
        CustomerHomeHeader(
          userName: widget.user['first_name'] ?? widget.user['email'] ?? '',
          location: _currentLocation,
          token: widget.token,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.0 * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Services",
                        style: TextStyle(
                          fontSize: 18 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServicesScreen(token: widget.token),
                            ),
                          );
                        },
                        child: Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 12 * scaleFactor,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scaleFactor),
                  SizedBox(
                    height: 130 * scaleFactor,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MerchantListScreen(
                                  serviceName: service['name']!,
                                  token: widget.token,
                                  customerId: widget.customerId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 90 * scaleFactor,
                            margin: EdgeInsets.only(right: 12 * scaleFactor),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 65 * scaleFactor,
                                  height: 65 * scaleFactor,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(service['image']!),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8 * scaleFactor),
                                Expanded(
                                  child: Text(
                                    service['name']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    "Recommended",
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12 * scaleFactor),
                  SizedBox(
                    height: 170 * scaleFactor,
                    child: FutureBuilder<List<Merchant>>(
                      future: fetchMerchants(widget.token),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Text('Failed to load saloons');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No saloons found');
                        } else {
                          final merchants = snapshot.data!;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: merchants.length,
                            itemBuilder: (context, index) {
                              final merchant = merchants[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MerchantServiceListScreen(
                                        merchantId: merchant.id,
                                        outletName: merchant.outletName,
                                        token: widget.token,
                                        customerId: widget.customerId,
                                        profileImageUrl: merchant.logoUrl,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 180 * scaleFactor,
                                  margin: EdgeInsets.only(right: 12 * scaleFactor),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                                        child: merchant.logoUrl.isNotEmpty
                                            ? Image.network(
                                                merchant.logoUrl,
                                                height: 100 * scaleFactor,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    'assets/saloonservice.jpg',
                                                    height: 100 * scaleFactor,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Container(
                                                    height: 100 * scaleFactor,
                                                    width: double.infinity,
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                loadingProgress.expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Image.asset(
                                                'assets/saloonservice.jpg',
                                                height: 100 * scaleFactor,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      SizedBox(height: 8 * scaleFactor),
                                      Text(
                                        merchant.outletName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15 * scaleFactor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        merchant.address,
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      FutureBuilder<Map<String, dynamic>>(
                                        future: _getMerchantRating(merchant.id),
                                        builder: (context, ratingSnapshot) {
                                          if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                            return Row(
                                              children: [
                                                SizedBox(
                                                  width: 12 * scaleFactor,
                                                  height: 12 * scaleFactor,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1.5,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                                SizedBox(width: 4 * scaleFactor),
                                                Text(
                                                  "Loading...",
                                                  style: TextStyle(
                                                    fontSize: 11 * scaleFactor,
                                                    color: Colors.grey,
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
                                                size: 14 * scaleFactor,
                                                color: reviewCount > 0 ? Colors.amber : Colors.grey,
                                              ),
                                              SizedBox(width: 2 * scaleFactor),
                                              Text(
                                                reviewCount > 0 
                                                    ? averageRating.toStringAsFixed(1)
                                                    : 'No rating',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13 * scaleFactor,
                                                  color: reviewCount > 0 ? Colors.black87 : Colors.grey,
                                                ),
                                              ),
                                              SizedBox(width: 4 * scaleFactor),
                                              Text(
                                                reviewCount > 0 
                                                    ? "| $reviewCount Review${reviewCount != 1 ? 's' : ''}"
                                                    : "| No reviews",
                                                style: TextStyle(
                                                  fontSize: 11 * scaleFactor,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 24 * scaleFactor),
                  Text(
                    "Nearest Saloon (within 10 km)",
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<Merchant>>(
                    future: fetchNearestMerchants(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Failed to load nearest saloons');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No saloons found within 10 km');
                      }

                      final nearestMerchants = snapshot.data!;
                      return ListView.builder(
                        itemCount: nearestMerchants.length > 3 ? 3 : nearestMerchants.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final merchant = nearestMerchants[index];
                          final distanceInKm = (_userPosition != null)
                              ? (getDistanceFromUser(_userPosition!, merchant) / 1000).toStringAsFixed(2)
                              : 'N/A';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: merchant.logoUrl.isNotEmpty
                                  ? NetworkImage(merchant.logoUrl)
                                  : const AssetImage('assets/images/default_logo.jpg') as ImageProvider,
                              backgroundColor: Colors.grey[200],
                            ),
                            title: Text(merchant.outletName),
                            subtitle: Text('${merchant.address}, $distanceInKm km away'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MerchantServiceListScreen(
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
                                backgroundColor: const Color.fromARGB(255, 133, 18, 179),
                              ),
                              child: const Text('Visit Now', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}