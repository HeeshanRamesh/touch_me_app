import 'package:flutter/gestures.dart' show OneSequenceGestureRecognizer;
import 'package:flutter/material.dart';
import 'horizontal_nav_bar.dart'; // Import the HorizontalNavBar
import 'package:flutter/foundation.dart'; // Import for Factory class
import 'one_saloon_inside_screen.dart'; // Import for navigation
import 'saloon_review_screen.dart'; // Import for navigation
import 'saloon_gift_card_screen.dart'; // Import for navigation
import 'saloon_portfolio_screen.dart'; // Import for navigation
// Import the MapScreen

class SaloonDetailScreen extends StatefulWidget {
  const SaloonDetailScreen({Key? key}) : super(key: key);

  @override
  _SaloonDetailScreenState createState() => _SaloonDetailScreenState();
}

class _SaloonDetailScreenState extends State<SaloonDetailScreen> {
  String _activeTab = 'Details'; // Default active tab

  @override
  void initState() {
    super.initState();
  }

  void _onTabSelected(String tab) {
    setState(() {
      _activeTab = tab;
    });

    // Handle navigation based on the selected tab
    if (tab == 'Services') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OneSaloonInsideScreen(
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
          'Salon Niro',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: HorizontalNavBar(
              tabs: const ['Services', 'Reviews', 'Portfolio', 'Gift Cards', 'Details'],
              activeTab: _activeTab,
              onTabSelected: _onTabSelected,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'We are dedicated to providing a personalized beauty experience. Our team of professionals is committed to helping you achieve your desired look with care and expertise.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Contact & Business Hours
                    const Text(
                      'Contact & Business Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildContactRow(Icons.phone, '071 456 78 90'),
                    const SizedBox(height: 16),
                    const Text(
                      'Monday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tuesday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Wednesday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thursday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Friday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Saturday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sunday',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '10:00 - 20:00',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Social Media & Share
                    const Text(
                      'Social Media & Share',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.grey),
                          onPressed: () {
                            // Handle Instagram share (placeholder)
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat, color: Colors.grey),
                          onPressed: () {
                            // Handle WhatsApp share (placeholder)
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.grey),
                          onPressed: () {
                            // Handle Telegram share (placeholder)
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.facebook, color: Colors.grey),
                          onPressed: () {
                            // Handle Facebook share (placeholder)
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Venue Amenities
                    const Text(
                      'Venue Amenities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAmenityRow(Icons.wifi, 'Wi-Fi'),
                    _buildAmenityRow(Icons.payment, 'Credit Card Accepted'),
                    _buildAmenityRow(Icons.accessible, 'Accessible for Disabled'),
                    _buildAmenityRow(Icons.local_parking, 'Free Parking'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
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
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}