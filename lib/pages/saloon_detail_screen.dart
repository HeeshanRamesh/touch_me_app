import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps
import 'package:touch_me/pages/horizontal_nav_bar.dart';
import 'package:flutter/foundation.dart'; // Import for Factory class
import 'one_saloon_inside_screen.dart'; // Import for navigation
import 'saloon_review_screen.dart'; // Import for navigation
import 'saloon_gift_card_screen.dart'; // Import for navigation
import 'saloon_portfolio_screen.dart'; // Import for navigation
import 'map_screen.dart'; // Import the MapScreen

class SaloonDetailScreen extends StatefulWidget {
  const SaloonDetailScreen({super.key});

  @override
  _SaloonDetailScreenState createState() => _SaloonDetailScreenState();
}

class _SaloonDetailScreenState extends State<SaloonDetailScreen> {
  String _activeTab = 'Details'; // Default active tab

  // Define the initial position for the map (example coordinates for Colombo, Sri Lanka)
  static const LatLng _salonLocation = LatLng(6.9271, 79.8612); // Example coordinates for Salon Niro
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Add a marker for Salon Niro
    _markers.add(
      const Marker(
        markerId: MarkerId('salon_niro'),
        position: _salonLocation,
        infoWindow: InfoWindow(title: 'Salon Niro'),
      ),
    );
  }

  void _onTabSelected(String tab) {
    setState(() {
      _activeTab = tab;
    });

    if (tab == 'Services') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => const OneSaloonInsideScreen(
                saloonName: 'Salon Niro',
                location: '123 Main St',
                rating: 5.0,
                reviews: 127,
                discount: '10% OFF',
                imagePath: 'assets/salon_image.jpg',
              ),
        ),
      );
    } else if (tab == 'Reviews') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaloonReviewScreen()),
      );
    } else if (tab == 'Gift Cards') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaloonGiftCardScreen()),
      );
    } else if (tab == 'Portfolio') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaloonPortfolioScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Salon Niro',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isLargeScreen ? 24.0 : 16.0,
              horizontal: isLargeScreen ? 32.0 : 0.0,
            ),
            child: HorizontalNavBar(
              tabs: const [
                'Services',
                'Reviews',
                'Portfolio',
                'Gift Cards',
                'Details',
              ],
              activeTab: _activeTab,
              onTabSelected: _onTabSelected,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 32.0 : 16.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 800 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Google Map with GestureDetector for navigation
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(
                              salonLocation: _salonLocation,
                              salonName: 'Salon Niro',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: _salonLocation,
                              zoom: 15,
                            ),
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                            // Disable interaction on this map since it's just a preview
                            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                            zoomGesturesEnabled: false,
                            scrollGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // About Us
                    const Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We are dedicated to providing a personalized beauty experience...',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact & Business Hours Section
                    _buildSectionTitle('Contact & Business Hours'),
                    const SizedBox(height: 8),
                    _buildContactRow(Icons.phone, '071 456 78 90'),
                    const SizedBox(height: 16),
                    if (isLargeScreen)
                      _buildBusinessHoursGrid()
                    else
                      ..._buildBusinessHoursList(),

                    const SizedBox(height: 24),

                    // Social Media Section
                    _buildSectionTitle('Social Media & Share'),
                    const SizedBox(height: 8),
                    _buildSocialMediaButtons(isLargeScreen),
                    const SizedBox(height: 24),

                    // Amenities Section
                    _buildSectionTitle('Venue Amenities'),
                    const SizedBox(height: 8),
                    if (isLargeScreen)
                      _buildAmenitiesGrid()
                    else
                      ..._buildAmenitiesList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSocialMediaButtons(bool isLargeScreen) {
    return Wrap(
      spacing: isLargeScreen ? 16 : 8,
      children: [
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.facebook, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAmenityRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAmenitiesList() {
    return [
      _buildAmenityRow(Icons.wifi, 'Wi-Fi'),
      _buildAmenityRow(Icons.payment, 'Credit Card Accepted'),
      _buildAmenityRow(Icons.accessible, 'Accessible for Disabled'),
      _buildAmenityRow(Icons.local_parking, 'Free Parking'),
    ];
  }

  Widget _buildAmenitiesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 5,
      children: [
        _buildAmenityRow(Icons.wifi, 'Wi-Fi'),
        _buildAmenityRow(Icons.payment, 'Credit Card Accepted'),
        _buildAmenityRow(Icons.accessible, 'Accessible for Disabled'),
        _buildAmenityRow(Icons.local_parking, 'Free Parking'),
      ],
    );
  }

  List<Widget> _buildBusinessHoursList() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days
        .map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '10:00 - 20:00',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildBusinessHoursGrid() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children:
          days
              .map(
                (day) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '10:00 - 20:00',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
