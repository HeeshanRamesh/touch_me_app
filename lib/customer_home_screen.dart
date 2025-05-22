import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'custom_bottom_nav_bar.dart';
import 'favourite_screen.dart';
import 'services/services.dart';
import 'inside_category_screen.dart';
import 'one_saloon_inside_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  late Future<List<Service>> _servicesFuture;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
      if (_authToken != null && _authToken!.isNotEmpty) {
        _refreshServices();
      } else {
        // Handle case where no token is found
        _servicesFuture = Future.value([]); // Empty list if no token
      }
    });
  }

  void _refreshServices() {
    if (_authToken != null) {
      setState(() {
        _servicesFuture = ServiceApi().fetchServices(_authToken!, context);
      });
    }
  }

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

  final List<Widget> _screens = [
    CustomerHomeContent(),
    const Center(child: Text('Grid Screen')),
    FavouriteScreen(),
    const ProfileScreen(),
  ];
}

class CustomerHomeContent extends StatefulWidget {
  const CustomerHomeContent({super.key});

  @override
  State<CustomerHomeContent> createState() => _CustomerHomeContentState();
}

class _CustomerHomeContentState extends State<CustomerHomeContent> {
  late Future<List<Service>> _servicesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parentState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
    if (parentState != null && parentState._authToken != null) {
      _servicesFuture = ServiceApi().fetchServices(parentState._authToken!, context);
    } else {
      _servicesFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentDateTime = DateTime(2025, 5, 19, 14, 5);
    final String formattedDateTime = DateFormat('EEEE, MMMM d, yyyy, hh:mm a Z')
        .format(currentDateTime.toUtc().add(const Duration(hours: 5, minutes: 30)));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: const Color(0xFF6A1B9A),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              const Text(
                'Arshan Sayed',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDateTime,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_pin, color: Color(0xFF6A1B9A), size: 16),
                    SizedBox(width: 4),
                    Text('Kesbewa', style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 14)),
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
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
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
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6A1B9A)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(leading: Icon(Icons.home), title: Text('Home')),
            ListTile(leading: Icon(Icons.message), title: Text('Messages')),
            ListTile(leading: Icon(Icons.category), title: Text('Categories')),
            ListTile(leading: Icon(Icons.bookmark), title: Text('Saved')),
            ListTile(leading: Icon(Icons.account_circle), title: Text('Profile')),
            ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
            ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    child: const Text('View all', style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: FutureBuilder<List<Service>>(
                future: _servicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load services: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              final parentState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
                              if (parentState != null) parentState._refreshServices();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No services available'));
                  }

                  final services = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final imageMap = {
                        'Haircut': 'assets/services/haircut_image.png',
                        'Massage': 'assets/services/massage_image.png',
                      };
                      final imagePath = imageMap[service.serviceName] ?? 'assets/services/default_image.png';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading $imagePath: $error');
                                    return const Icon(Icons.image_not_supported, color: Colors.grey, size: 30);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(service.serviceName, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Special Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  const List<Map<String, dynamic>> specialOffers = [
                    {'title': 'Salon Niro', 'location': '121/A, Kesbewa, Piliyandala', 'rating': 4.5, 'reviews': 236, 'discount': 'Save Up To 10%', 'imagePath': 'assets/offers/offer1.png'},
                    {'title': 'Prasa With Duli', 'location': '112/A, Yakkala, Gampaha', 'rating': 4.5, 'reviews': 155, 'discount': 'Save Up To 15%', 'imagePath': 'assets/offers/offer2.png'},
                    {'title': 'Salon Niro', 'location': '121/A, Kesbewa, Piliyandala', 'rating': 4.5, 'reviews': 236, 'discount': 'Save Up To 10%', 'imagePath': 'assets/offers/offer3.png'},
                    {'title': 'Prasa With Duli', 'location': '112/A, Yakkala, Gampaha', 'rating': 4.5, 'reviews': 155, 'discount': 'Save Up To 15%', 'imagePath': 'assets/offers/offer4.png'},
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                child: Image.asset(
                                  offer['imagePath'],
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading ${offer['imagePath']}: $error');
                                    return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(offer['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(offer['location'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.yellow, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${offer['rating']} (${offer['reviews']} Reviews)', style: const TextStyle(fontSize: 12)),
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
                                            Text(offer['discount'], style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Recommended', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  const List<Map<String, dynamic>> recommended = [
                    {'title': 'Priya Salon', 'location': '12/B, Bokundara, Maharagama', 'rating': 5.0, 'reviews': 336, 'discount': 'Save Up To 10%', 'imagePath': 'assets/offers/offer4.png'},
                    {'title': 'Leo Max Men Salon', 'location': '23/A, Wijerama, Nugegoda', 'rating': 4.8, 'reviews': 255, 'discount': 'Save Up To 10%', 'imagePath': 'assets/offers/offer3.png'},
                    {'title': 'Priya Salon', 'location': '12/B, Bokundara, Maharagama', 'rating': 5.0, 'reviews': 336, 'discount': 'Save Up To 10%', 'imagePath': 'assets/offers/offer2.png'},
                    {'title': 'Leo Max Men Salon', 'location': '23/A, Wijerama, Nugegoda', 'rating': 4.8, 'reviews': 255, 'discount': 'Save Up To 10%', 'imagePath': 'assets/offers/offer1.png'},
                  ];
                  final item = recommended[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                              child: Image.asset(
                                item['imagePath'],
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Error loading ${item['imagePath']}: $error');
                                  return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(item['location'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${item['rating']} (${item['reviews']} Reviews)', style: const TextStyle(fontSize: 12)),
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
                                          Text(item['discount'], style: const TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nearest Saloon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    child: Text('View all', style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                const List<Map<String, dynamic>> nearestSaloons = [
                  {'title': 'Lotas Saloon', 'location': 'Colombo Havelock Road', 'rating': 4.5, 'imagePath': 'assets/saloons/lotas_saloon_image.png'},
                  {'title': 'Glamour Grove Studio', 'location': 'Colombo Havelock Road', 'rating': 4.5, 'imagePath': 'assets/saloons/glamour_grove_image.png'},
                  {'title': 'Lotas Saloon', 'location': 'Colombo Havelock Road', 'rating': 4.5, 'imagePath': 'assets/saloons/lotas_saloon_image_2.png'},
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
                      child: saloon['imagePath'] == 'assets/services/default_image.png'
                          ? const Icon(Icons.image_not_supported, color: Colors.grey)
                          : null,
                    ),
                    title: Text(saloon['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_pin, color: Colors.grey, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(saloon['location'], style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            Text('${saloon['rating']}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
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