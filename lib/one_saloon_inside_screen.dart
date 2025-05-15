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
  String _activeTab = 'Services';

  void _onTabSelected(String tab) {
    setState(() => _activeTab = tab);

    switch (tab) {
      case 'Reviews':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaloonReviewScreen()),
        );
        break;
      case 'Gift Cards':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaloonGiftCardScreen()),
        );
        break;
      case 'Portfolio':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaloonPortfolioScreen()),
        );
        break;
      case 'Details':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SaloonDetailScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF6A1B9A),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.image, size: 100),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.saloonName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.rating} (${widget.reviews} Reviews)',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.purple,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HorizontalNavBar(
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
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for Service',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildServiceExpansion('Popular Services', true),
                  const SizedBox(height: 12),
                  _buildServiceExpansion('Other Services', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceExpansion(String title, bool initiallyExpanded) {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Haircut & Beard',
        'desc': 'Trims and styles hair for grooming and personality.',
        'price': 40.0,
        'duration': '30m',
        'discount': 'Save Up To 10%',
      },
      {
        'title': 'Edge Up',
        'desc': 'Sharp clean haircut edges and styling.',
        'price': 30.0,
        'duration': '25m',
        'discount': 'Save Up To 10%',
      },
    ];

    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: initiallyExpanded,
      children:
          services.map((service) {
            return _buildServiceCard(
              context,
              service['title'],
              service['desc'],
              service['price'],
              service['duration'],
              service['discount'],
            );
          }).toList(),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      duration,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentScreen(),
                      ),
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
          ],
        ),
      ),
    );
  }
}
