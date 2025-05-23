import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:touch_me/upcoming_appointment_screen.dart';
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
    _servicesFuture = Future.value([]); // Initialize with empty list
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _authToken = prefs.getString('auth_token');
        _refreshServices();
      });
    } catch (e) {
      debugPrint('Error loading token: $e');
      setState(() {
        _servicesFuture = Future.value([]);
      });
    }
  }

  void _refreshServices() {
    if (_authToken != null && _authToken!.isNotEmpty) {
      setState(() {
        _servicesFuture = ServiceApi().fetchServices(_authToken!, context);
      });
    } else {
      setState(() {
        _servicesFuture = Future.value([]);
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
    const CustomerHomeContent(),
    const UpcomingAppointmentScreen(),
    const FavouriteScreen(),
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
    _servicesFuture = parentState?._authToken != null
        ? ServiceApi().fetchServices(parentState!._authToken!, context)
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    // Responsive scaling
    final screenWidth = MediaQuery.of(context).size.width;
    const referenceWidth = 375.0;
    final scaleFactor = screenWidth / referenceWidth;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final DateTime currentDateTime = DateTime.now();
    final String formattedDateTime = DateFormat('EEEE, MMMM d, yyyy, hh:mm a Z')
        .format(currentDateTime.toUtc().add(const Duration(hours: 5, minutes: 30)));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120 * scaleFactor),
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
              Text(
                'Good ${currentDateTime.hour < 12 ? 'Morning' : 'Evening'}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18 * scaleFactor,
                ),
              ),
              SizedBox(height: 4 * scaleFactor),
              Text(
                'Arshan Sayed',
                style: TextStyle(color: Colors.white, fontSize: 14 * scaleFactor),
              ),
              SizedBox(height: 4 * scaleFactor),
              Text(
                formattedDateTime,
                style: TextStyle(color: Colors.white, fontSize: 12 * scaleFactor),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.0 * scaleFactor),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20 * scaleFactor),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: const Color(0xFF6A1B9A),
                      size: 16 * scaleFactor,
                    ),
                    SizedBox(width: 4 * scaleFactor),
                    Text(
                      'Kesbewa',
                      style: TextStyle(
                        color: const Color(0xFF6A1B9A),
                        fontSize: 14 * scaleFactor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60 * scaleFactor),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0 * scaleFactor,
                vertical: 8.0 * scaleFactor,
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search your service',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 16 * scaleFactor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30 * scaleFactor),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30 * scaleFactor),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30 * scaleFactor),
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
              decoration: const BoxDecoration(color: Color(0xFF6A1B9A)),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, size: 16 * scaleFactor),
              title: Text('Home', style: TextStyle(fontSize: 14 * scaleFactor)),
              onTap: () {
                Navigator.pop(context);
                final parentState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
                parentState?._onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.message, size: 16 * scaleFactor),
              title: Text('Messages', style: TextStyle(fontSize: 14 * scaleFactor)),
            ),
            ListTile(
              leading: Icon(Icons.category, size: 16 * scaleFactor),
              title: Text('Categories', style: TextStyle(fontSize: 14 * scaleFactor)),
            ),
            ListTile(
              leading: Icon(Icons.bookmark, size: 16 * scaleFactor),
              title: Text('Saved', style: TextStyle(fontSize: 14 * scaleFactor)),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, size: 16 * scaleFactor),
              title: Text('Profile', style: TextStyle(fontSize: 14 * scaleFactor)),
              onTap: () {
                final parentState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
                parentState?._onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, size: 16 * scaleFactor),
              title: Text('Settings', style: TextStyle(fontSize: 14 * scaleFactor)),
            ),
            ListTile(
              leading: Icon(Icons.logout, size: 16 * scaleFactor),
              title: Text('Logout', style: TextStyle(fontSize: 14 * scaleFactor)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0 * scaleFactor,
                vertical: 8.0 * scaleFactor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: const Color(0xFF6A1B9A),
                        fontSize: 14 * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100 * scaleFactor,
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
                          Text(
                            'Failed to load services: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14 * scaleFactor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8 * scaleFactor),
                          ElevatedButton(
                            onPressed: () {
                              final parentState = context.findAncestorStateOfType<_CustomerHomeScreenState>();
                              parentState?._refreshServices();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12 * scaleFactor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No services available',
                        style: TextStyle(fontSize: 14 * scaleFactor),
                      ),
                    );
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
                      final imagePath =
                          imageMap[service.serviceName] ?? 'assets/services/default_image.png';

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0 * scaleFactor),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30 * scaleFactor,
                              backgroundColor: Colors.grey[200],
                              child: ClipOval(
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: 60 * scaleFactor,
                                  height: 60 * scaleFactor,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading $imagePath: $error');
                                    return Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 30 * scaleFactor,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 4 * scaleFactor),
                            Text(
                              service.serviceName,
                              style: TextStyle(fontSize: 12 * scaleFactor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0 * scaleFactor,
                vertical: 8.0 * scaleFactor,
              ),
              child: Text(
                'Special Offers',
                style: TextStyle(
                  fontSize: 18 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220 * scaleFactor,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  const List<Map<String, dynamic>> specialOffers = [
                    {
                      'title': 'Salon Niro',
                      'location': '121/A, Kesbewa, Piliyandala',
                      'rating': 4.5,
                      'reviews': 236,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer1.png'
                    },
                    {
                      'title': 'Prasa With Duli',
                      'location': '112/A, Yakkala, Gampaha',
                      'rating': 4.5,
                      'reviews': 155,
                      'discount': 'Save Up To 15%',
                      'imagePath': 'assets/offers/offer2.png'
                    },
                    {
                      'title': 'Salon Niro',
                      'location': '121/A, Kesbewa, Piliyandala',
                      'rating': 4.5,
                      'reviews': 236,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer3.png'
                    },
                    {
                      'title': 'Prasa With Duli',
                      'location': '112/A, Yakkala, Gampaha',
                      'rating': 4.5,
                      'reviews': 155,
                      'discount': 'Save Up To 15%',
                      'imagePath': 'assets/offers/offer4.png'
                    },
                  ];
                  final offer = specialOffers[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * scaleFactor),
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
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                        child: SizedBox(
                          width: 250 * scaleFactor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10 * scaleFactor),
                                  topRight: Radius.circular(10 * scaleFactor),
                                ),
                                child: Image.asset(
                                  offer['imagePath'],
                                  height: 100 * scaleFactor,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading ${offer['imagePath']}: $error');
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 100 * scaleFactor,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0 * scaleFactor),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offer['title'],
                                      style: TextStyle(
                                        fontSize: 16 * scaleFactor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scaleFactor),
                                    Text(
                                      offer['location'],
                                      style: TextStyle(
                                        fontSize: 12 * scaleFactor,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scaleFactor),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 16 * scaleFactor,
                                        ),
                                        SizedBox(width: 4 * scaleFactor),
                                        Text(
                                          '${offer['rating']} (${offer['reviews']} Reviews)',
                                          style: TextStyle(fontSize: 12 * scaleFactor),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4 * scaleFactor),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.discount,
                                              color: Colors.purple,
                                              size: 16 * scaleFactor,
                                            ),
                                            SizedBox(width: 4 * scaleFactor),
                                            Text(
                                              offer['discount'],
                                              style: TextStyle(
                                                fontSize: 12 * scaleFactor,
                                                color: Colors.purple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.favorite_border,
                                          color: Colors.purple,
                                          size: 16 * scaleFactor,
                                        ),
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0 * scaleFactor,
                vertical: 8.0 * scaleFactor,
              ),
              child: Text(
                'Recommended',
                style: TextStyle(
                  fontSize: 18 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 220 * scaleFactor,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  const List<Map<String, dynamic>> recommended = [
                    {
                      'title': 'Priya Salon',
                      'location': '12/B, Bokundara, Maharagama',
                      'rating': 5.0,
                      'reviews': 336,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer4.png'
                    },
                    {
                      'title': 'Leo Max Men Salon',
                      'location': '23/A, Wijerama, Nugegoda',
                      'rating': 4.8,
                      'reviews': 255,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer3.png'
                    },
                    {
                      'title': 'Priya Salon',
                      'location': '12/B, Bokundara, Maharagama',
                      'rating': 5.0,
                      'reviews': 336,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer2.png'
                    },
                    {
                      'title': 'Leo Max Men Salon',
                      'location': '23/A, Wijerama, Nugegoda',
                      'rating': 4.8,
                      'reviews': 255,
                      'discount': 'Save Up To 10%',
                      'imagePath': 'assets/offers/offer1.png'
                    },
                  ];
                  final item = recommended[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0 * scaleFactor),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                      child: SizedBox(
                        width: 250 * scaleFactor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10 * scaleFactor),
                                topRight: Radius.circular(10 * scaleFactor),
                              ),
                              child: Image.asset(
                                item['imagePath'],
                                height: 100 * scaleFactor,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Error loading ${item['imagePath']}: $error');
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 100 * scaleFactor,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0 * scaleFactor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: TextStyle(
                                      fontSize: 16 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scaleFactor),
                                  Text(
                                    item['location'],
                                    style: TextStyle(
                                      fontSize: 12 * scaleFactor,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scaleFactor),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 16 * scaleFactor,
                                      ),
                                      SizedBox(width: 4 * scaleFactor),
                                      Text(
                                        '${item['rating']} (${item['reviews']} Reviews)',
                                        style: TextStyle(fontSize: 12 * scaleFactor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4 * scaleFactor),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.discount,
                                            color: Colors.purple,
                                            size: 16 * scaleFactor,
                                          ),
                                          SizedBox(width: 4 * scaleFactor),
                                          Text(
                                            item['discount'],
                                            style: TextStyle(
                                              fontSize: 12 * scaleFactor,
                                              color: Colors.purple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.favorite_border,
                                        color: Colors.purple,
                                        size: 16 * scaleFactor,
                                      ),
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
              padding: EdgeInsets.symmetric(
                horizontal: 16.0 * scaleFactor,
                vertical: 8.0 * scaleFactor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearest Saloon',
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: const Color(0xFF6A1B9A),
                        fontSize: 14 * scaleFactor,
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
                const List<Map<String, dynamic>> nearestSaloons = [
                  {
                    'title': 'Lotas Saloon',
                    'location': 'Colombo Havelock Road',
                    'rating': 4.5,
                    'imagePath': 'assets/saloons/lotas_saloon_image.png'
                  },
                  {
                    'title': 'Glamour Grove Studio',
                    'location': 'Colombo Havelock Road',
                    'rating': 4.5,
                    'imagePath': 'assets/saloons/glamour_grove_image.png'
                  },
                  {
                    'title': 'Lotas Saloon',
                    'location': 'Colombo Havelock Road',
                    'rating': 4.5,
                    'imagePath': 'assets/saloons/lotas_saloon_image_2.png'
                  },
                ];
                final saloon = nearestSaloons[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16 * scaleFactor,
                    vertical: 8 * scaleFactor,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30 * scaleFactor,
                      backgroundImage: AssetImage(saloon['imagePath']),
                      onBackgroundImageError: (error, stackTrace) {
                        debugPrint('Error loading ${saloon['imagePath']}: $error');
                      },
                      child: saloon['imagePath'] == 'assets/services/default_image.png'
                          ? Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 30 * scaleFactor,
                            )
                          : null,
                    ),
                    title: Text(
                      saloon['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * scaleFactor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Colors.grey,
                              size: 16 * scaleFactor,
                            ),
                            SizedBox(width: 4 * scaleFactor),
                            Expanded(
                              child: Text(
                                saloon['location'],
                                style: TextStyle(
                                  fontSize: 12 * scaleFactor,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4 * scaleFactor),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 16 * scaleFactor,
                            ),
                            SizedBox(width: 4 * scaleFactor),
                            Text(
                              '${saloon['rating']}',
                              style: TextStyle(fontSize: 12 * scaleFactor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20 * scaleFactor),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12 * scaleFactor,
                        ),
                      ),
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