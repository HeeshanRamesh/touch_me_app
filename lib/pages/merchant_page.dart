import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/pages/client_page.dart';
import 'package:touch_me/pages/merchant_login_page.dart';
import 'package:touch_me/pages/merchant_notification.dart';
import 'package:touch_me/pages/merchant_profile_page.dart';
import 'package:touch_me/pages/merchant_services_screen.dart';
import 'package:touch_me/pages/merchant_setting_page.dart';
import 'package:touch_me/pages/my_bookings_page.dart';
import 'package:touch_me/pages/online_booking_show_page.dart';
import 'package:touch_me/pages/report_page.dart';
import 'package:touch_me/pages/saloon_dashboard_screen.dart';
import 'package:touch_me/pages/service_merchant_page.dart';
import 'package:touch_me/pages/team_page.dart';


class MerchantPage extends StatefulWidget {
  final String? userName; // Make userName nullable
  const MerchantPage({super.key, this.userName});

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  int _currentIndex = 0;
  String _displayName = ''; // Store the display name

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final storage = const FlutterSecureStorage();
    String? storedUserName = await storage.read(key: "userName");
    setState(() {
      _displayName = storedUserName ?? widget.userName ?? 'Unknown';
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 15) return "Good Afternoon";
    if (hour < 19) return "Good Evening";
    return "Good Night";
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    IconData? icon,
    String? imagePath, // Added for optional image
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath,
                width: 50,
                height: 45,
                color: color, // Optional: to tint the image with the color
              )
            else if (icon != null)
              Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 229, 229),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 2) {
            final storage = const FlutterSecureStorage();
            String? merchantId = await storage.read(key: "merchantId");
            if (merchantId == null || merchantId.isEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Merchant ID not found. Please login again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MerchantServicesScreen(merchantId: merchantId),
                ),
              );
            }
          } else if (index == 1) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsPage()),
              );
            }
          } else if (index == 3) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MerchantProfilePage(userName: _displayName),
                ),
              );
            }
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.design_services), label: "Services"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Color(0xFF6A1B9A)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationPage()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      PopupMenuButton<String>(
                        offset: const Offset(0, 50), // Positions the popup below the CircleAvatar
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.purple,
                          child: Text(
                            _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        onSelected: (value) async {
                          if (value == 'logout') {
                            // Clear stored data
                            final storage = const FlutterSecureStorage();
                            await storage.delete(key: "userName");
                            await storage.delete(key: "merchantId");
                            //await storage.delete(key: "userEmail");
                            if (context.mounted) {
                              // Navigate to login page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const MerchantLoginPage()),
                              );
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              enabled: false, // Disable selection for name and email
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName.isNotEmpty ? _displayName : 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // const SizedBox(height: 4),
                                  // FutureBuilder<String?>(
                                  //   future: const FlutterSecureStorage().read(key: "userEmail"),
                                  //   builder: (context, snapshot) {
                                  //     return Text(
                                  //       snapshot.data ?? 'No email available',
                                  //       style: const TextStyle(
                                  //         fontSize: 14,
                                  //         color: Colors.grey,
                                  //       ),
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: const [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Logout', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFFB71C9B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search Clients, Services",
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (query) {
                          // Handle search query
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 40,
                childAspectRatio: 0.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFeatureTile(
                    context,
                    icon: Icons.home,
                    title: "Home",
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SaloonDashboardScreen(userName: '')),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    imagePath: 'assets/target-audience.png',
                    title: "Clients",
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CompletedBookingsPage()),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    imagePath: 'assets/booking.png',
                    title: "Bookings",
                    color: const Color(0xFFB71C9B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OnlineBookingShowPage(userName: _displayName)),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    imagePath: 'assets/consulting.png',
                    title: "Services",
                    color: const Color(0xFFB71C9B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ServiceMerchantPage(userName: _displayName)),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    imagePath: 'assets/result.png',
                    title: "Reports",
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportPage()),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    imagePath: 'assets/settings.png',
                    title: "Settings",
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MerchantSettingPage()),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    imagePath: 'assets/group-chat.png',
                    title: "Team",
                    color: const Color(0xFFB71C9B),
                    onTap: () async {
                      final storage = const FlutterSecureStorage();
                      String? merchantId = await storage.read(key: "merchantId");
                      if (merchantId == null || merchantId.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Merchant ID not found. Please login again."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TeamPage(userName: _displayName)),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder Pages
class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: const Center(child: Text("Clients Management Page")),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: const Center(child: Text("Profile Page")),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: const Center(child: Text("Reports and Analytics Page")),
    );
  }
}

class AddOnsPage extends StatelessWidget {
  const AddOnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add-ons")),
      body: const Center(child: Text("Add-ons Management Page")),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(child: Text("Settings and Preferences Page")),
    );
  }
}