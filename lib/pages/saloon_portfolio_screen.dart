import 'package:flutter/material.dart';
import 'package:touch_me/pages/horizontal_nav_bar.dart';
import 'one_saloon_inside_screen.dart'; // Import for navigation
import 'saloon_review_screen.dart'; // Import for navigation
import 'saloon_gift_card_screen.dart'; // Import for navigation
import 'saloon_detail_screen.dart'; // Import for navigation

class SaloonPortfolioScreen extends StatefulWidget {
  const SaloonPortfolioScreen({super.key});

  @override
  _SaloonPortfolioScreenState createState() => _SaloonPortfolioScreenState();
}

class _SaloonPortfolioScreenState extends State<SaloonPortfolioScreen> {
  String _activeTab = 'Portfolio'; // Default active tab

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
    } else if (tab == 'Details') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaloonDetailScreen()),
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
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.75, // Adjust for image height
              ),
              itemCount: 5, // Number of images as per screenshot
              itemBuilder: (context, index) {
                return _buildPortfolioCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                'assets/portfolio_image.jpg', // Replace with your image path
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading portfolio image: $error');
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Icons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    // Handle share action (placeholder)
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        // Handle like action (placeholder)
                      },
                    ),
                    const Text(
                      '0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}