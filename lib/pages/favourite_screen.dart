import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/pages/merchant_service_list_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/review.dart'; // Import Review model
import '../services/reviews.dart'; // Import review service

class FavouriteScreen extends StatefulWidget {
  final String token;
  final String customerId;

  const FavouriteScreen({
    super.key,
    required this.token,
    required this.customerId,
  });

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<Map<String, dynamic>> _favoriteSalons = [];
  bool _isLoading = false;
  final _storage = FlutterSecureStorage();
  Map<String, Map<String, dynamic>> _merchantRatings =
      {}; // Cache for merchant ratings

  @override
  void initState() {
    super.initState();
    _loadFavoriteSalons();
  }

  // Load favorite salons from API
  Future<void> _loadFavoriteSalons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await _storage.read(key: 'user_id') ?? widget.customerId;
      debugPrint('Loading favorites for user ID: $userId');

      final response = await http.get(
        Uri.parse('http://api.touchmeapp.com/api/users/$userId/favorites'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['favorites'] != null) {
          final List<dynamic> favorites = data['favorites'];

          setState(() {
            _favoriteSalons =
                favorites
                    .map((favorite) {
                      final owner = favorite['owner'] ?? {};
                      final outlet = favorite['outlet'] ?? {};
                      final businessRegistration =
                          favorite['businessRegistration'] ?? {};

                      // Enhanced logging for debugging
                      debugPrint('Processing favorite: ${favorite.toString()}');
                      debugPrint(
                        'Business Registration: $businessRegistration',
                      );

                      // Use 'logo' instead of 'logoUrl'
                      String imageUrl =
                          businessRegistration['logo']?.isNotEmpty == true
                              ? businessRegistration['logo']
                              : '';

                      String salonName =
                          outlet['name'] ?? owner['name'] ?? 'Unknown Salon';

                      debugPrint('Logo URL for $salonName: $imageUrl');
                      debugPrint(
                        'Owner Phone: ${owner['phone']}, Outlet Phone: ${outlet['phone']}, Outlet Address: ${outlet['address']}',
                      );

                      // Skip salons with no name or invalid data (optional)
                      if (salonName == 'Unknown Salon' && imageUrl.isEmpty) {
                        debugPrint(
                          'Skipping salon with insufficient data: $favorite',
                        );
                        return null;
                      }

                      return {
                        'name': salonName,
                        'location':
                            owner['phone'] ??
                            outlet['phone'] ??
                            'Phone not available', // Phone number
                        'imagePath': imageUrl,
                        'isFavorite': true,
                        'merchantId': favorite['merchantId'] ?? '',
                        'outletPhone':
                            owner['phone'] ??
                            outlet['phone'] ??
                            '', // Phone number
                        'outletAddress': outlet['address'] ?? '', // Address
                        'email':
                            owner['email'] ??
                            '', // Store email separately if needed
                        'openingHours': outlet['openingHours'] ?? {},
                      };
                    })
                    .where((salon) => salon != null)
                    .cast<Map<String, dynamic>>()
                    .toList();
          });

          // Fetch ratings for all favorite salons
          for (var salon in _favoriteSalons) {
            await _getMerchantRating(salon['merchantId']);
          }

          debugPrint(
            'Loaded ${_favoriteSalons.length} favorite salons from API',
          );
        } else {
          debugPrint('No favorites array found in API response');
          setState(() {
            _favoriteSalons = [];
          });
        }
      } else if (response.statusCode == 404) {
        debugPrint('No favorites found for user');
        setState(() {
          _favoriteSalons = [];
        });
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        _showErrorMessage('Failed to load favorites. Please try again.');
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _showErrorMessage('Network error. Please check your connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculate review stats
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

  // Fetch merchant rating
  Future<Map<String, dynamic>> _getMerchantRating(String merchantId) async {
    if (_merchantRatings.containsKey(merchantId)) {
      return _merchantRatings[merchantId]!;
    }

    try {
      final reviews = await fetchReviewsByMerchant(merchantId, widget.token);
      final stats = _calculateReviewStats(reviews);
      setState(() {
        _merchantRatings[merchantId] = stats;
      });
      return stats;
    } catch (e) {
      debugPrint('Error fetching reviews for merchant $merchantId: $e');
      final defaultStats = {"average": 0.0, "count": 0};
      setState(() {
        _merchantRatings[merchantId] = defaultStats;
      });
      return defaultStats;
    }
  }

  // Show error message
  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Remove favorite via API
  Future<void> _removeFavorite(int index) async {
    final merchantId = _favoriteSalons[index]['merchantId'];
    final userId = await _storage.read(key: 'user_id') ?? widget.customerId;

    debugPrint('Removing favorite: merchantId=$merchantId, userId=$userId');

    try {
      final response = await http.delete(
        Uri.parse('http://api.touchmeapp.com/api/users/$userId/favorites'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'merchantId': merchantId}),
      );

      debugPrint(
        'Remove favorite response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        setState(() {
          _favoriteSalons.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from favorites'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (response.statusCode == 404) {
        debugPrint('Favorite not found: ${response.body}');
        _showErrorMessage('Favorite not found. Please try again.');
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        _showErrorMessage('Failed to remove from favorites');
      }
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      _showErrorMessage('Network error. Please try again.');
    }
  }

  // Add a new favorite salon via API
  Future<void> _addFavorite(String merchantId) async {
    final userId = await _storage.read(key: 'user_id') ?? widget.customerId;

    try {
      final response = await http.post(
        Uri.parse('http://api.touchmeapp.com/api/users/$userId/favorites'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'merchantId': merchantId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Added merchant $merchantId to favorites');
        await _loadFavoriteSalons();
      } else {
        debugPrint(
          'Failed to add favorite: ${response.statusCode} - ${response.body}',
        );
        _showErrorMessage('Failed to add to favorites');
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      _showErrorMessage('Network error. Please try again.');
    }
  }

  // Refresh favorites
  Future<void> _refreshFavorites() async {
    await _loadFavoriteSalons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245),
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshFavorites,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
              )
              : _favoriteSalons.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorite salons yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _refreshFavorites,
                      child: const Text(
                        'Tap to refresh',
                        style: TextStyle(color: Color(0xFF6A1B9A)),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _refreshFavorites,
                color: const Color(0xFF6A1B9A),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _favoriteSalons.length,
                  itemBuilder: (context, index) {
                    final salon = _favoriteSalons[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MerchantServiceListScreen(
                                  merchantId: salon['merchantId'],
                                  outletName: salon['name'],
                                  token: widget.token,
                                  customerId: widget.customerId,
                                  profileImageUrl: salon['imagePath'],
                                ),
                          ),
                        );
                      },
                      child: _buildSalonCard(
                        salon['name'],
                        salon['merchantId'],
                        salon['location'], // Phone number
                        salon['outletPhone'], // Phone number
                        salon['outletAddress'], // Address
                        salon['imagePath'],
                        salon['isFavorite'],
                        index,
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildSalonCard(
    String name,
    String merchantId,
    String location,
    String phone,
    String address,
    String imagePath,
    bool isFavorite,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child:
                  imagePath.isNotEmpty
                      ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                color: const Color(0xFF6A1B9A),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            'Error loading logo for $name: $imagePath, Error: $error',
                          );
                          return Image.asset(
                            'assets/saloonservice.jpg',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint(
                                'Error loading fallback asset for $name: $error',
                              );
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.storefront,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          );
                        },
                      )
                      : Image.asset(
                        'assets/saloonservice.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint(
                            'Error loading fallback asset for $name: $error',
                          );
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.storefront,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.purple : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => _removeFavorite(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getMerchantRating(merchantId),
                    builder: (context, ratingSnapshot) {
                      if (ratingSnapshot.connectionState ==
                          ConnectionState.waiting) {
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
                              "Loading...",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      }
                      final stats =
                          ratingSnapshot.data ?? {"average": 0.0, "count": 0};
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
                                ? '${averageRating.toStringAsFixed(1)} ($reviewCount Review${reviewCount != 1 ? 's' : ''})'
                                : 'No rating',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  reviewCount > 0
                                      ? Colors.black87
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          phone, // Display phone number
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address, // Display address
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
