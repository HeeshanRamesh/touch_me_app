import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  // Sample list of favorite salons and spas
  final List<Map<String, dynamic>> _favoriteSalons = [
    {
      'name': 'Crazy & Windy',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/crazy_windy.png',
      'isFavorite': true,
    },
    {
      'name': 'Miro & Miro',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/miro_miro.png',
      'isFavorite': true,
    },
    {
      'name': 'Saloon & Spa by William',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/saloon_spa_william.png',
      'isFavorite': true,
    },
    {
      'name': 'BNY Saloon',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/bny_saloon.png',
      'isFavorite': true,
    },
    {
      'name': 'sny Saloon',
      'rating': 4.5,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/sny_spa.png',
      'isFavorite': true,
    },
    {
      'name': 'scy Saloon',
      'rating': 4.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/scy_spa.png',
      'isFavorite': true,
    },
    {
      'name': 'Ladies Magic',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/favourites/ladies_magic.png',
      'isFavorite': true,
    },
  ];

  String _selectedFilter = 'All'; // Track the selected filter
  List<Map<String, dynamic>> _filteredSalons = []; // Filtered list

  @override
  void initState() {
    super.initState();
    _filteredSalons = _favoriteSalons; // Initially show all
  }

  void _toggleFavorite(int index) {
    setState(() {
      _filteredSalons[index]['isFavorite'] = !_filteredSalons[index]['isFavorite'];
      if (!_filteredSalons[index]['isFavorite']) {
        _filteredSalons.removeAt(index);
        // Update the original list as well
        final salonName = _filteredSalons[index]['name'];
        final originalIndex = _favoriteSalons.indexWhere((salon) => salon['name'] == salonName);
        if (originalIndex != -1) {
          _favoriteSalons[originalIndex]['isFavorite'] = false;
        }
      }
      // Reapply the filter after toggling favorite
      _applyFilter(_selectedFilter);
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredSalons = _favoriteSalons.where((salon) => salon['isFavorite']).toList();
      } else if (filter == 'Salons') {
        _filteredSalons = _favoriteSalons
            .where((salon) =>
                salon['isFavorite'] &&
                (salon['name'].toString().toLowerCase().contains('saloon') ||
                    salon['name'].toString().toLowerCase().contains('salon')))
            .toList();
      } else if (filter == 'Spas') {
        _filteredSalons = _favoriteSalons
            .where((salon) =>
                salon['isFavorite'] && salon['name'].toString().toLowerCase().contains('spa'))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245), // Light grey color
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
          // Filter Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton('All', _selectedFilter == 'All'),
                _buildFilterButton('Salons', _selectedFilter == 'Salons'),
                _buildFilterButton('Spas', _selectedFilter == 'Spas'),
              ],
            ),
          ),
          // Salon/Spa List
          Expanded(
            child: _filteredSalons.isEmpty
                ? const Center(
                    child: Text(
                      'No favorite salons or spas yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredSalons.length,
                    itemBuilder: (context, index) {
                      final salon = _filteredSalons[index];
                      return _buildSalonCard(
                        salon['name'],
                        salon['rating'],
                        salon['reviews'],
                        salon['location'],
                        salon['imagePath'],
                        salon['isFavorite'],
                        index,
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
          // Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint('Error loading $imagePath: $exception');
                },
              ),
            ),
            child: null,
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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