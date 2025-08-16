import 'package:flutter/material.dart';
import 'package:touch_me/pages/horizontal_nav_bar.dart';
import 'one_saloon_inside_screen.dart'; // Import for navigation
import 'saloon_review_screen.dart'; // Import for navigation
import 'saloon_portfolio_screen.dart'; // Import for navigation
import 'saloon_detail_screen.dart'; // Import for navigation

class SaloonGiftCardScreen extends StatefulWidget {
  const SaloonGiftCardScreen({super.key});

  @override
  _SaloonGiftCardScreenState createState() => _SaloonGiftCardScreenState();
}

class _SaloonGiftCardScreenState extends State<SaloonGiftCardScreen> {
  String _activeTab = 'Gift Cards'; // Default active tab

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
    } else if (tab == 'Portfolio') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SaloonPortfolioScreen()),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 4, // Number of gift cards as per screenshot
              itemBuilder: (context, index) {
                return _buildGiftCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background with circular patterns
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                  ),
                  ...List.generate(
                    20,
                    (index) => Positioned(
                      left: (index % 5) * 50.0 - 20,
                      top: (index ~/ 5) * 50.0 - 20,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Gift Card Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GIFT CARD',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '15,000 LKR toward any service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All Services & Products',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard,
                            size: 16,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Salon Niro',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(
                      '15,000 LKR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Value',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(
                      '15,000 LKR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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