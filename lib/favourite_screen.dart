import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/merchant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'merchant_service_list_screen.dart'; // Import for navigation

class FavouriteScreen extends StatefulWidget {
  final String token; // Add token for navigation
  final String customerId; // Add customerId for navigation

  const FavouriteScreen({
    super.key,
    required this.token,
    required this.customerId,
  });

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _filteredSalons = [];
  List<Merchant> _favoriteMerchants = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteMerchants();
  }

  // Load favorite merchants from SharedPreferences and fetch their details
  Future<void> _loadFavoriteMerchants() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_salons') ?? [];
    if (favoriteIds.isEmpty) {
      setState(() {
        _filteredSalons = [];
        _favoriteMerchants = [];
      });
      return;
    }

    // Fetch merchant details from API
    final merchants = await _fetchMerchants(favoriteIds);
    setState(() {
      _favoriteMerchants = merchants;
      _applyFilter(_selectedFilter);
    });
  }

  // Fetch merchant details from API
  Future<List<Merchant>> _fetchMerchants(List<String> ids) async {
    try {
      final response = await http.get(
        Uri.parse('http://api.touchmeapp.com/api/merchants?ids=${ids.join(',')}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Merchant.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch merchants: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching merchants: $e');
      return [];
    }
  }

  // Toggle favorite status and save to SharedPreferences
  Future<void> _toggleFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_salons') ?? [];
    final merchantId = _filteredSalons[index]['merchantId'];

    setState(() {
      favorites.remove(merchantId);
      prefs.setStringList('favorite_salons', favorites);
      _filteredSalons.removeAt(index);
      _favoriteMerchants.removeWhere((merchant) => merchant.id == merchantId);
      _applyFilter(_selectedFilter); // Re-apply filter to update UI
    });
  }

  // Apply filter to _filteredSalons
  void _applyFilter(String filter) {
    final prefs = SharedPreferences.getInstance();
    setState(() {
      _selectedFilter = filter;
      _filteredSalons = _favoriteMerchants
          .where((merchant) {
            if (filter == 'All') return true;
            if (filter == 'Salons') {
              return merchant.outletName.toLowerCase().contains('saloon') ||
                  merchant.outletName.toLowerCase().contains('salon');
            }
            return false;
          })
          .map((merchant) => {
                'name': merchant.outletName,
                'rating': 5.0, // Static rating for consistency
                'reviews': 127, // Static reviews for consistency
                'location': '12/214, ${merchant.outletPhone}',
                'imagePath': merchant.logoUrl,
                'isFavorite': true, // All merchants here are favorites
                'merchantId': merchant.id,
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('All', _selectedFilter == 'All'),
                _buildFilterButton('Salons', _selectedFilter == 'Salons'),
                // _buildFilterButton('Spas', _selectedFilter == 'Spas'),
              ],
            ),
          ),
          Expanded(
            child: _filteredSalons.isEmpty
                ? const Center(
                    child: Text(
                      'No favorite salons yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredSalons.length,
                    itemBuilder: (context, index) {
                      final salon = _filteredSalons[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MerchantServiceListScreen(
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
                          salon['rating'],
                          salon['reviews'],
                          salon['location'],
                          salon['imagePath'],
                          salon['isFavorite'],
                          index,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _applyFilter(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.purple : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSalonCard(
    String name,
    double rating,
    int reviews,
    String location,
    String imagePath,
    bool isFavorite,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint('Error loading $imagePath: $exception');
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
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.purple : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviews Reviews)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      const Icon(Icons.location_pin, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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