import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:touch_me/merchant_signup_main.dart';

class SaloonMapScreen extends StatefulWidget {
  const SaloonMapScreen({super.key});

  @override
  _SaloonMapScreenState createState() => _SaloonMapScreenState();
}

class _SaloonMapScreenState extends State<SaloonMapScreen> {
  // List of latest posts
  final List<Map<String, String>> latestPosts = [
    {
      'name': 'Amy Liu ',
      'location': 'Latest in New York',
      'imageUrl': 'assets/coffee_shop.png', // Replace with your image asset
      'description': 'Maybe Coffee shop - 2.8km',
      'time': '2 days ago',
    },
  ];

  // Google Maps Controller
  late GoogleMapController _mapController;

  // Initial position (New York coordinates)
  static const LatLng _initialPosition = LatLng(40.7128, -74.0060); // New York

  // Set of markers (one marker for the coffee shop)
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('coffee_shop'),
      position: _initialPosition,
      infoWindow: InfoWindow(
        title: 'Maybe Coffee Shop',
        snippet: '2.8km away',
      ),
    ),
  };

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Saloon Map',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar with Categories
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Try Gas Stations, ATMs...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.black),
                  onPressed: () {
                    // Handle voice search
                  },
                ),
              ],
            ),
          ),
          // Google Map
          SizedBox(
            height: 200.0,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true, // Optional: Show user's location
              myLocationButtonEnabled: true, // Optional: Show location button
            ),
          ),
          // Latest Posts Section
          Expanded(
            child: ListView.builder(
              itemCount: latestPosts.length,
              itemBuilder: (context, index) {
                final post = latestPosts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://via.placeholder.com/40'), // Replace with actual user image
                            radius: 20,
                          ),
                          title: Text(post['name']!),
                          subtitle: Text(post['location']!),
                          trailing: TextButton(
                            onPressed: () {
                              // Handle follow action
                            },
                            child: const Text('Follow'),
                          ),
                        ),
                        Image.asset(
                          post['imageUrl']!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            post['description']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(post['time']!),
                              Row(
                                children: const [
                                  Icon(Icons.thumb_up, size: 16),
                                  SizedBox(width: 4),
                                  Text('5.0 ★'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MerchantSignupMain()),
      );
              
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}