import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  // Sample list of favorite salons (you can replace this with a real data source)
  final List<Map<String, dynamic>> _favoriteSalons = [
    {
      'name': 'Crazy & Windy',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/crazy_windy.jpg',
      'isFavorite': true,
    },
    {
      'name': 'Miro & Miro',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/miro_miro.jpg',
      'isFavorite': true,
    },
    {
      'name': 'Saloon & Spa by William',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/saloon_spa_william.jpg',
      'isFavorite': true,
    },
    {
      'name': 'BNY Saloon',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/bny_saloon.jpg',
      'isFavorite': true,
    },
    {
      'name': 'Ladies Magic',
      'rating': 5.0,
      'reviews': 127,
      'location': 'No 6/1, Main Street',
      'imagePath': 'assets/ladies_magic.jpg',
      'isFavorite': true,
    },
  ];

  void _toggleFavorite(int index) {
    setState(() {
      _favoriteSalons[index]['isFavorite'] = !_favoriteSalons[index]['isFavorite'];
      // If the salon is unfavorited, remove it from the list
      if (!_favoriteSalons[index]['isFavorite']) {
        _favoriteSalons.removeAt(index);
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
      body: _favoriteSalons.isEmpty
          ? const Center(
              child: Text(
                'No favorite salons yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _favoriteSalons.length,
              itemBuilder: (context, index) {
                final salon = _favoriteSalons[index];
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
            child: imagePath == null
                ? const Icon(Icons.image, color: Colors.grey, size: 50)
                : null,
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