import 'package:flutter/material.dart';
import 'appoinment_screen.dart'; // Import the AppointmentScreen
import 'saloon_review_screen.dart'; // Import the SaloonReviewScreen
import 'saloon_gift_card_screen.dart'; // Import the SaloonGiftCardScreen
import 'horizontal_nav_bar.dart'; // Import the HorizontalNavBar
import 'saloon_portfolio_screen.dart'; // Import the SaloonPortfolioScreen
import 'saloon_detail_screen.dart'; // Import the SaloonDetailScreen

class OneSaloonInsideScreen extends StatefulWidget {
  final String saloonName;
  final String location;
  final double rating;
  final int reviews;
  final String discount;
  final String imagePath;

  const OneSaloonInsideScreen({
    super.key,
    required this.saloonName,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.discount,
    required this.imagePath,
  });

  @override
  _OneSaloonInsideScreenState createState() => _OneSaloonInsideScreenState();
}

class _OneSaloonInsideScreenState extends State<OneSaloonInsideScreen> {
  String _activeTab = 'Services'; // Default active tab

  void _onTabSelected(String tab) {
    setState(() {
      _activeTab = tab;
    });

    // Handle navigation based on the selected tab
    if (tab == 'Reviews') {
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
      body: CustomScrollView(
        slivers: [
          // SliverAppBar for the header with image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6A1B9A), // Purple color
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading ${widget.imagePath}: $error');
                      return const Icon(Icons.image, size: 100, color: Colors.grey);
                    },
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SliverToBoxAdapter for the rest of the content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.saloonName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_pin, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                widget.location,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellow, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.rating} (${widget.reviews} Reviews)',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.discount,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.purple),
                            onPressed: () {
                              // Handle favorite action
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Horizontal Navigation Bar
                  HorizontalNavBar(
                    tabs: const ['Services', 'Reviews', 'Portfolio', 'Gift Cards', 'Details'],
                    activeTab: _activeTab,
                    onTabSelected: _onTabSelected,
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for Service',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Popular Services Section with ExpansionTile
                  ExpansionTile(
                    title: const Text(
                      'Popular Services',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: true, // Open by default
                    children: [
                      _buildServiceCard(
                        context,
                        'Haircut & Beard',
                        'A haircut trims and styles hair, enhancing appearance, reflecting personality, and maintaining grooming.',
                        40.00,
                        '30m',
                        'Save Up To 10%',
                      ),
                      _buildServiceCard(
                        context,
                        'Haircut & Beard',
                        'A haircut trims and styles hair, enhancing appearance, reflecting personality, and maintaining grooming.',
                        50.00,
                        '55m',
                        'Save Up To 10%',
                      ),
                      _buildServiceCard(
                        context,
                        'Edge Up',
                        'A haircut trims and styles hair, enhancing appearance, reflecting personality, and maintaining grooming.',
                        30.00,
                        '25m',
                        'Save Up To 10%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Other Services Section with ExpansionTile
                  ExpansionTile(
                    title: const Text(
                      'Other Services',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: false, // Closed by default
                    children: [
                      _buildServiceCard(
                        context,
                        'Kidscut',
                        'A haircut trims and styles hair, enhancing appearance, reflecting personality, and maintaining grooming.',
                        40.00,
                        '45m',
                        'Save Up To 10%',
                      ),
                      _buildServiceCard(
                        context,
                        'Beard',
                        'A haircut trims and styles hair, enhancing appearance, reflecting personality, and maintaining grooming.',
                        25.00,
                        '20m',
                        'Save Up To 10%',
                      ),
                      _buildServiceCard(
                        context,
                        'Haircut & Beard',
                        'A haircut trims and styles hair, enhancing appearance, reflecting personality, and maintaining grooming.',
                        50.00,
                        '55m',
                        'Save Up To 15%',
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

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String description,
    double price,
    String duration,
    String discount,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        duration,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to AppointmentScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Book',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}