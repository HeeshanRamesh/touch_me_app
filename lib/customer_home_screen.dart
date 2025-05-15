import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:touch_me/barbershop_service_screen.dart';
import 'package:touch_me/hair_services_screen.dart';
import 'package:touch_me/location_select_screen.dart';
import 'package:touch_me/massage_service_screen.dart';
import 'package:touch_me/search_screen.dart';
import 'package:touch_me/custom_bottom_nav_bar.dart';
import 'package:touch_me/inside_category_screen.dart';
import 'package:touch_me/favourite_screen.dart';
import 'package:touch_me/profile_screen.dart';
import 'package:touch_me/one_saloon_inside_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeContent(),
    const Center(child: Text('Grid Screen')),
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

class CustomerHomeContent extends StatefulWidget {
  const CustomerHomeContent({super.key});

  @override
  State<CustomerHomeContent> createState() => _CustomerHomeContentState();
}

class _CustomerHomeContentState extends State<CustomerHomeContent> {
  String _selectedLocationText = 'Kesbewa';

  Future<void> _openLocationSelector() async {
    final LatLng? selectedLatLng = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSelectScreen()),
    );
    if (selectedLatLng != null && mounted) {
      try {
        final placemarks = await placemarkFromCoordinates(
          selectedLatLng.latitude,
          selectedLatLng.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _selectedLocationText = [
              place.locality,
              place.subAdministrativeArea,
              place.administrativeArea,
            ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
          });
        }
      } catch (_) {
        setState(() => _selectedLocationText = 'Location not found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFFB71C9B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 32,
                    bottom: 50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Good Morning',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Arshan Sayed',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _openLocationSelector,
                        icon: const Icon(
                          Icons.location_pin,
                          size: 16,
                          color: Color(0xFF6A1B9A),
                        ),
                        label: Text(
                          _selectedLocationText,
                          style: const TextStyle(
                            color: Color(0xFF6A1B9A),
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 130,
                  left: 20,
                  right: 20,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Your Service',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Services Section
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
  height: 90,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: 9,
    itemBuilder: (context, index) {
      final List<Map<String, dynamic>> services = [
        {
          'name': 'Hair Salon',
          'image': 'assets/services/Ellipse 326.png',
        },
        {
          'name': 'Barbershop',
          'image': 'assets/services/Ellipse 325.png',
        },
        {
          'name': 'Massage',
          'image': 'assets/services/Ellipse 327.png',
        },
        {
          'name': 'Skin Care',
          'image': 'assets/services/Ellipse 328.png',
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
        child: GestureDetector(
          onTap: () {
            if (service['name'] == 'Hair Salon') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HairServiceScreen(),
                ),
              );
            } else if (service['name'] == 'Barbershop') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BarberServiceScreen(),
                ),
              );
            } else if (service['name'] == 'Massage') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MassageServiceScreen(),
                ),
              );
            }
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(service['image']),
              ),
              const SizedBox(height: 4),
              Text(
                service['name'],
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    },
  ),
),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Text(
                'Saloons',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220,
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
            // Recommended Section
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
              height: 220,
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
            // Nearest Saloon Section
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