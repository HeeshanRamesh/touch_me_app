import 'package:flutter/material.dart';
import 'package:touch_me/one_saloon_inside_screen.dart';
import 'package:touch_me/service_filter_page.dart';
import 'merchant_list_screen.dart';
import 'models/merchant.dart';
import 'services/merchant_service.dart';
import 'my_gift_cards_screen.dart';

class CustomerHomeHeader extends StatelessWidget {
  final String userName;
  final String location;
  final String token;

  const CustomerHomeHeader({
    super.key,
    required this.userName,
    required this.location,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ Color(0xFF9D1E96), Color(0xFF7E1878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // App icon and location row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                 // borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/touch_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF6A1B9A),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   // decoration: BoxDecoration(
              //   //   color: Colors.white,
              //   //   borderRadius: BorderRadius.circular(20),
              //   // ),
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 14,
              //     vertical: 6,
              //   ),
              //   child: Row(
              //     children: [
              //       const Icon(
              //         Icons.notifications,
              //         color: Color(0xFF6A1B9A),
              //         size: 18,
              //       ),                   
              //     ],
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 30),
          // Search field
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              readOnly: false,
              decoration: const InputDecoration(
                hintText: "Search Your Service",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 24,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onTap: () {
                // Open search screen if needed
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerHomeContent extends StatelessWidget {
  final String token;
  final String customerId;
  final Map<String, dynamic> user;

  const CustomerHomeContent({
    super.key,
    required this.token,
    required this.customerId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;

    final List<Map<String, String>> services = [
      {'name': 'Haircut & Styling - Ladies ', 'image': 'assets/services/haircut_image.png'},
      {'name': 'Haircut & Styling - Gents', 'image': 'assets/services/Ellipse 325.png'},
      {'name': 'Haircut & Styling - Kids', 'image': 'assets/services/kid.png'},
      {'name': 'Haircut & Styling - Adults', 'image': 'assets/services/old.png'},
      {'name': 'Massage', 'image': 'assets/services/massage_image.png'},
      {'name': 'Bridal', 'image': 'assets/services/bridal.png'},
      {'name': 'Tattoo & Piercing', 'image': 'assets/services/tattoo_image.png'},
      {
        'name': 'Facials & Skincare',
        'image': 'assets/services/Ellipse 328.png',
      },
      {
        'name': 'Hair Removal',
        'image': 'assets/services/hair_removal_image.png',
      },
      {'name': 'Nails', 'image': 'assets/services/nail_salon_image.png'},
      {
        'name': 'Eyebrow & EyeLashes',
        'image': 'assets/services/brows_lashes_image.png',
      },
      {'name': 'Injectable & Fillers', 'image': 'assets/services/piercing_image.png'},
      {'name': 'Makeup', 'image': 'assets/services/makeup_image.png'},
      {'name': 'Dressing', 'image': 'assets/services/dress.png'},
      {'name': 'Pedicure & Manicure', 'image': 'assets/services/image.png'},
      {'name': 'Door Step Service', 'image': 'assets/services/home.png'},
    ];

    return Column(
      children: [
        CustomerHomeHeader(
          userName: user['first_name'] ?? user['email'] ?? '',
          location: 'Kesbewa',
          token: token,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.0 * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SERVICES SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Services",
                        style: TextStyle(
                          fontSize: 18 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServicesScreen(
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "View all",
                          style: TextStyle(
                            fontSize: 12 * scaleFactor,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scaleFactor),
                  SizedBox(
                    height: 130 * scaleFactor,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MerchantListScreen(
                                      serviceName: service['name']!,
                                      token: token,
                                      customerId: customerId,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            width: 90 * scaleFactor,
                            margin: EdgeInsets.only(right: 12 * scaleFactor),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 65 * scaleFactor,
                                  height: 65 * scaleFactor,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(service['image']!),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8 * scaleFactor),

                                Expanded(
                                  child: Text(
                                    service['name']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11 * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      height: 1.2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  //SizedBox(height:5),
                  // Saloons Section (dynamic)
                  Text(
                    "Recommended",
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12 * scaleFactor),
                  SizedBox(
                    height: 170 * scaleFactor,
                    child: FutureBuilder<List<Merchant>>(
                      future: fetchMerchants(token),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Text('Failed to load saloons');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No saloons found');
                        } else {
                          final merchants = snapshot.data!;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: merchants.length,
                            itemBuilder: (context, index) {
                              final merchant = merchants[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => OneSaloonInsideScreen(
                                  //        saloonName: '${merchant.outletName}', location: '', rating: 0, reviews: 0, discount: '', imagePath: '',
                                  //     ),
                                  //   ),
                                  // );
                                },
                                child: Container(
                                  width: 180 * scaleFactor,
                                  margin: EdgeInsets.only(
                                    right: 12 * scaleFactor,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12 * scaleFactor,
                                        ),
                                        child: Image.asset(
                                          'assets/saloonservice.jpg',
                                          height: 100 * scaleFactor,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 8 * scaleFactor),
                                      Text(
                                        merchant.outletName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15 * scaleFactor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        merchant.address,
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          color: Colors.grey,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14 * scaleFactor,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 2 * scaleFactor),
                                          Text(
                                            merchant.rating?.toString() ?? '5.0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13 * scaleFactor,
                                            ),
                                          ),
                                          SizedBox(width: 4 * scaleFactor),
                                          Text(
                                            "| ${(merchant.reviews ?? 0).toString()} Reviews",
                                            style: TextStyle(
                                              fontSize: 11 * scaleFactor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 24 * scaleFactor),
                  // Nearest Saloon Section (dummy)
                  Text(
                    "Nearest Saloon",
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/saloons/lotas_saloon_image.png',
                          ),
                        ),
                        title: const Text('Lotas Saloon'),
                        subtitle: const Text('Colombo Havelock Road'),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              133,
                              18,
                              179,
                            ),
                          ),
                          child: const Text('Book Now',
                            style: TextStyle(color: Colors.white),
                          
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}