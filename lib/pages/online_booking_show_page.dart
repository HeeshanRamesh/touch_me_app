import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/pages/appoinment_calender.dart';
import 'package:touch_me/pages/merchant_page.dart';
import 'package:touch_me/pages/merchant_services_screen.dart';
import 'package:touch_me/pages/my_bookings_page.dart';

class OnlineBookingShowPage extends StatefulWidget {
  final String userName;
  const OnlineBookingShowPage({Key? key, required this.userName}) : super(key: key);

  @override
  State<OnlineBookingShowPage> createState() => _OnlineBookingShowPageState();
}

class _OnlineBookingShowPageState extends State<OnlineBookingShowPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(
                          "Booking Details",
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Booking Calendar'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppointmentBookingPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('My Appointments'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyBookingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          } else if (index == 0) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MerchantPage(userName: widget.userName)),
              );
            }
          } else if (index == 1) {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsPage()),
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
    );
  }
}