import 'package:flutter/material.dart';
import 'horizontal_nav_bar.dart'; // Import the HorizontalNavBar
import 'one_saloon_inside_screen.dart'; // Import for navigation
import 'saloon_gift_card_screen.dart'; // Import for navigation
import 'saloon_portfolio_screen.dart'; // Import for navigation
import 'saloon_detail_screen.dart'; // Import for navigation

class SaloonReviewScreen extends StatefulWidget {
  const SaloonReviewScreen({Key? key}) : super(key: key);

  @override
  _SaloonReviewScreenState createState() => _SaloonReviewScreenState();
}

class _SaloonReviewScreenState extends State<SaloonReviewScreen> {
  String _activeTab = 'Reviews'; // Default active tab

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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Summary
                    Row(
                      children: [
                        const Text(
                          '5.0',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '127 Reviews',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Star Rating Breakdown
                    Column(
                      children: [
                        _buildStarRow(5, 127),
                        _buildStarRow(4, 0),
                        _buildStarRow(3, 0),
                        _buildStarRow(2, 0),
                        _buildStarRow(1, 0),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Note
                    Text(
                      'Note: you can explore honest, first-hand feedback from customers who have experienced top-notch services at our partner salon.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reviews List
                    _buildReviewCard(
                      userName: 'Ruwini Fernando',
                      date: '29 Dec 2024',
                      service: 'Hair Cut, Facial',
                      reviewText:
                          'I visited Salon Niro for a haircut, and I couldn’t be more pleased with the experience. From the moment I walked in, the atmosphere was welcoming and relaxing. The staff were incredibly professional, and my style took the...',
                    ),
                    _buildReviewCard(
                      userName: 'Ruwini Fernando',
                      date: '29 Dec 2024',
                      service: 'Hair Cut, Facial',
                      reviewText:
                          'I visited Salon Niro for a haircut, and I couldn’t be more pleased with the experience. From the moment I walked in, the atmosphere was welcoming and relaxing. The staff were incredibly professional, and my style took the...',
                    ),
                    _buildReviewCard(
                      userName: 'Ruwini Fernando',
                      date: '29 Dec 2024',
                      service: 'Hair Cut, Facial',
                      reviewText:
                          'I visited Salon Niro for a haircut, and I couldn’t be more pleased with the experience. From the moment I walked in, the atmosphere was welcoming and relaxing. The staff were incredibly professional, and my style took the...',
                    ),
                    _buildReviewCard(
                      userName: 'Ruwini Fernando',
                      date: '29 Dec 2024',
                      service: 'Hair Cut, Facial',
                      reviewText:
                          'I visited Salon Niro for a haircut, and I couldn’t be more pleased with the experience. From the moment I walked in, the atmosphere was welcoming and relaxing. The staff were incredibly professional, and my style took the...',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(int stars, int count) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.star,
          color: Colors.yellow,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: count / 127, // Assuming 127 is the total number of reviews
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String userName,
    required String date,
    required String service,
    required String reviewText,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reviewText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Handle "Show More" action (not implemented)
              },
              child: const Text(
                'Show More',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}