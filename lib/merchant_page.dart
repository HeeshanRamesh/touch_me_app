import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/merchant_catalog_page.dart';
import 'package:touch_me/merchant_profile_page.dart';
import 'package:touch_me/merchant_services_screen.dart';
import 'package:touch_me/merchant_setting_page.dart';
import 'package:touch_me/my_bookings_page.dart';
import 'package:touch_me/online_booking_show_page.dart';
import 'package:touch_me/report_page.dart';
import 'package:touch_me/saloon_dashboard_screen.dart';
import 'package:touch_me/service_merchant_page.dart';
import 'package:touch_me/team_page.dart';

class MerchantPage extends StatefulWidget {
  final String userName;
  const MerchantPage({super.key, required this.userName});

  @override
  State<MerchantPage> createState() => _MerchantPageState();
}

class _MerchantPageState extends State<MerchantPage> {
  int _currentIndex = 0;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
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
      backgroundColor: const Color.fromARGB(255, 234, 229, 229), // Updated to a light gray background
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          if (index == 2) {
            // Load merchantId from secure storage
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
            // Bookings tab
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsPage()),
              );
            }
          } else if (index == 3) {
            // Bookings tab
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MerchantProfilePage(userName: '',)),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: "Services",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.notifications),
          //   label: "Notifications",
          // ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Greeting, Name, Location, and Profile/Notifications
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
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFE0D7F6),
                      //     borderRadius: BorderRadius.circular(20),
                      //   ),
                        
                      // ),

                       IconButton(
                        icon: const Icon(Icons.notifications, color: Color(0xFF6A1B9A)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsPage()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.purple,
                        child: Text(
                          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),              
                      // IconButton(
                      //   icon: const Icon(Icons.person, color: Color(0xFF6A1B9A)),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (_) => const ProfilePage()),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search Bar
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
              // Feature Tiles Grid
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
                    icon: Icons.home

,
                    title: "Home",
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SaloonDashboardScreen(userName: '',)),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.face_2,
                    title: "Clients",
                    color: const Color(0xFF6A1B9A),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClientsPage()),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.calendar_today,
                    title: "Online Booking",
                    color: const Color(0xFFB71C9B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnlineBookingShowPage()),
                      );
                    },
                  ),
                  // _buildFeatureTile(
                  //   context,
                  //   icon: Icons.store,
                  //   title: "Catalog",
                  //   color: const Color(0xFF6A1B9A),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (_) => const MerchantCatalogPage()),
                  //     );
                  //   },
                  // ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.design_services,
                    title: "Services",
                    color: const Color(0xFFB71C9B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ServiceMerchantPage()),
                      );
                    },
                  ),
                  _buildFeatureTile(
                    context,
                    icon: Icons.description,
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
                    icon: Icons.settings,
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
                    icon: Icons.group,
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
                          MaterialPageRoute(
                            builder: (_) => TeamPage(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Customer Acquisition Chart
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFF9F9F9),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text(
              //         "Overall Customer Acquisition",
              //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              //       ),
              //       const SizedBox(height: 20),
              //       SizedBox(
              //         height: 200,
              //         child: BarChart(
              //           BarChartData(
              //             barGroups: List.generate(12, (index) {
              //               return BarChartGroupData(
              //                 x: index,
              //                 barRods: [
              //                   BarChartRodData(
              //                     toY: (index + 5) * 5.0,
              //                     color: const Color(0xFF6A1B9A),
              //                     width: 14,
              //                     borderRadius: BorderRadius.circular(4),
              //                   ),
              //                 ],
              //               );
              //             }),
              //             titlesData: FlTitlesData(
              //               bottomTitles: AxisTitles(
              //                 sideTitles: SideTitles(
              //                   showTitles: true,
              //                   getTitlesWidget: (value, meta) {
              //                     const months = [
              //                       'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
              //                       'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
              //                     ];
              //                     return Text(
              //                       months[value.toInt() % 12],
              //                       style: const TextStyle(fontSize: 10),
              //                     );
              //                   },
              //                 ),
              //               ),
              //               leftTitles: AxisTitles(
              //                 sideTitles: SideTitles(
              //                   showTitles: true,
              //                   reservedSize: 30,
              //                 ),
              //               ),
              //               topTitles: const AxisTitles(
              //                 sideTitles: SideTitles(showTitles: false),
              //               ),
              //               rightTitles: const AxisTitles(
              //                 sideTitles: SideTitles(showTitles: false),
              //               ),
              //             ),
              //             gridData: const FlGridData(show: false),
              //             borderData: FlBorderData(show: false),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: const Center(child: Text("Notifications Page")),
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