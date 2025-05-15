import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart'; // Import the CustomBottomNavBar
import 'one_saloon_inside_screen.dart'; // Import the OneSaloonInsideScreen
import 'search_screen.dart'; // Import the SearchScreen
import 'inside_category_screen.dart'; // Import the InsideCategoryScreen
import 'favourite_screen.dart'; // Import the FavouriteScreen
import 'profile_screen.dart'; // Import the ProfileScreen

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0; // Track the selected bottom navigation item

  // List of screens to display based on the selected index
  final List<Widget> _screens = [
    const CustomerHomeContent(), // Home screen content
    const Center(child: Text('Grid Screen')), // Replace with actual GridScreen
    const FavouriteScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customNavBar = CustomBottomNavBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      onSearchPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InsideCategoryScreen()),
        );
      },
    );

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: customNavBar,
      floatingActionButton: customNavBar.getFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Extracted CustomerHomeScreen content into a separate widget for clarity
class CustomerHomeContent extends StatelessWidget {
  const CustomerHomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Height for AppBar with search bar
        child: AppBar(
          backgroundColor: const Color(0xFF6A1B9A), // Purple color
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Arshan Sayed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  // Handle location tracker action
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Color(0xFF6A1B9A),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Kesbewa',
                      style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                readOnly: true, // Prevent keyboard from appearing
                onTap: () {
                  // Navigate to SearchScreen when the search bar is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search your service',
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
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6A1B9A),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Services Section (Horizontal list of circular items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to view all services page
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 90, // Adjusted height for CircleAvatar (radius: 30) + Text
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 9,
                itemBuilder: (context, index) {
                  final List<Map<String, dynamic>> services = [
                    {
                      'name': 'Wellness & Spa',
                      'image': 'assets/services/wellness_spa_image.png',
                    },
                    {
                      'name': 'Braids & Locs',
                      'image': 'assets/services/braids_locs_image.png',
                    },
                    {
                      'name': 'Tattoo',
                      'image': 'assets/services/tattoo_image.png',
                    },
                    {
                      'name': 'Aesthetic Medicine',
                      'image': 'assets/services/aesthetic_medicine_image.png',
                    },
                    {
                      'name': 'Hair Removal',
                      'image': 'assets/services/hair_removal_image.png',
                    },
                    {
                      'name': 'Nail Salon',
                      'image': 'assets/services/nail_salon_image.png',
                    },
                    {
                      'name': 'Brows & Lashes',
                      'image': 'assets/services/brows_lashes_image.png',
                    },
                    {
                      'name': 'Piercing',
                      'image': 'assets/services/piercing_image.png',
                    },
                    {
                      'name': 'Makeup',
                      'image': 'assets/services/makeup_image.png',
                    },
                  ];
                  final service = services[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(service['image']),
                          onBackgroundImageError: (error, stackTrace) {
                            debugPrint('Error loading ${service['image']}: $error');
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['name'],
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Special Offers Section (Horizontal list of cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Text(
                'Special Offers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220, // Height to accommodate card content without overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final List<Map<String, dynamic>> specialOffers = [
                    {
                      'title': 'Salon Niro',
                      'location': '121/A, Kesbewa, Piliyandala',
                      'rating': 4.5,
                      'reviews': 236,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer1.png',
                    },
                    {
                      'title': 'Prasa With Duli',
                      'location': '112/A, Yakkala, Gampaha',
                      'rating': 4.5,
                      'reviews': 155,
                      'discount': 'Save Up To 15%',
                      'imagePath': 'assets/offers/offer2.png',
                    },
                    {
                      'title': 'Salon Niro',
                      'location': '121/A, Kesbewa, Piliyandala',
                      'rating': 4.5,
                      'reviews': 236,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer3.png',
                    },
                    {
                      'title': 'Prasa With Duli',
                      'location': '112/A, Yakkala, Gampaha',
                      'rating': 4.5,
                      'reviews': 155,
                      'discount': 'Save Up To 15%',
                      'imagePath': 'assets/offers/offer4.png',
                    },
                  ];
                  final offer = specialOffers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to OneSaloonInsideScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OneSaloonInsideScreen(
                              saloonName: offer['title'],
                              location: offer['location'],
                              rating: offer['rating'],
                              reviews: offer['reviews'],
                              discount: offer['discount'],
                              imagePath: offer['imagePath'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                child: Image.asset(
                                  offer['imagePath'],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading ${offer['imagePath']}: $error');
                                    return const Icon(Icons.image, size: 100, color: Colors.grey);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      offer['location'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.yellow, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${offer['rating']} (${offer['reviews']} Reviews)',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.discount, color: Colors.purple, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              offer['discount'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Icon(Icons.favorite_border, color: Colors.purple, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Recommended Section (Horizontal list of cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Text(
                'Recommended',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220, // Height to accommodate card content without overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  final List<Map<String, dynamic>> recommended = [
                    {
                      'title': 'Priya Salon',
                      'location': '12/B, Bokundara, Maharagama',
                      'rating': 5.0,
                      'reviews': 336,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer4.png',
                    },
                    {
                      'title': 'Leo Max Men Salon',
                      'location': '23/A, Wijerama, Nugegoda',
                      'rating': 4.8,
                      'reviews': 255,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer3.png',
                    },
                    {
                      'title': 'Priya Salon',
                      'location': '12/B, Bokundara, Maharagama',
                      'rating': 5.0,
                      'reviews': 336,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer2.png',
                    },
                    {
                      'title': 'Leo Max Men Salon',
                      'location': '23/A, Wijerama, Nugegoda',
                      'rating': 4.8,
                      'reviews': 255,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer1.png',
                    },
                  ];
                  final item = recommended[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.asset(
                                item['imagePath'],
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Error loading ${item['imagePath']}: $error');
                                  return const Icon(Icons.image, size: 100, color: Colors.grey);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['location'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item['rating']} (${item['reviews']} Reviews)',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.discount, color: Colors.purple, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['discount'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.favorite_border, color: Colors.purple, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Nearest Saloon Section (Vertical list of cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nearest Saloon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to view all nearest saloons page
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> nearestSaloons = [
                  {
                    'title': 'Lotas Saloon',
                    'location': 'Colombo Havelock Road',
                    'rating': 4.5,
                    'imagePath': 'assets/saloons/lotas_saloon_image.png',
                  },
                  {
                    'title': 'Glamour Grove Studio',
                    'location': 'Colombo Havelock Road',
                    'rating': 4.5,
                    'imagePath': 'assets/saloons/glamour_grove_image.png',
                  },
                  {
                    'title': 'Lotas Saloon',
                    'location': 'Colombo Havelock Road',
                    'rating': 4.5,
                    'imagePath': 'assets/saloons/lotas_saloon_image_2.png',
                  },
                ];
                final saloon = nearestSaloons[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(saloon['imagePath']),
                      onBackgroundImageError: (error, stackTrace) {
                        debugPrint('Error loading ${saloon['imagePath']}: $error');
                      },
                    ),
                    title: Text(
                      saloon['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_pin, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                saloon['location'],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${saloon['rating']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Handle book now action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      // Navigate to saloon details page
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}