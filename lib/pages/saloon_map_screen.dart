import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
      'location': 'Latest in Your Area',
      'imageUrl': 'assets/coffee_shop.png', // Replace with your image asset
      'description': 'Maybe Coffee shop - 2.8km',
      'time': '2 days ago',
    },
  ];

  // Google Maps Controller
  GoogleMapController? _mapController;

  // Current position (will be set dynamically)
  LatLng? _currentPosition;
  
  // Default position (fallback if location services fail)
  static const LatLng _defaultPosition = LatLng(40.7128, -74.0060);

  // Set of markers
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        _setDefaultLocation();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        _setDefaultLocation();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _updateMarkers();
      });

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      _setDefaultLocation();
    }
  }

  // Set default location if current location fails
  void _setDefaultLocation() {
    setState(() {
      _currentPosition = _defaultPosition;
      _updateMarkers();
    });
  }

  // Update markers based on current position
  void _updateMarkers() {
    if (_currentPosition != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        // You can add more markers for nearby saloons here
        Marker(
          markerId: const MarkerId('coffee_shop'),
          position: LatLng(
            _currentPosition!.latitude + 0.01, // Slightly offset from current location
            _currentPosition!.longitude + 0.01,
          ),
          infoWindow: const InfoWindow(
            title: 'Maybe Coffee Shop',
            snippet: '2.8km away',
          ),
        ),
      };
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
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
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.black),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
          ),
          // Google Map
          SizedBox(
            height: 200.0,
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 15.0,
                    ),
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false, // We added our own button
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
                Navigator.pop(context);
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