import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:touch_me/appoinment_calender.dart';
import 'package:touch_me/merchant_page.dart';
import 'package:touch_me/my_bookings_page.dart';
import 'package:touch_me/merchant_services_screen.dart';

class OnlineBookingShowPage extends StatefulWidget {
  const OnlineBookingShowPage({Key? key}) : super(key: key);

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Name
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: const Text(
                          "Booking Details",
                          style: TextStyle(
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
              // Appointment Date Card
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
                      leading: Icon(Icons.calendar_month),
                      title: Text('Booking Calender'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AppointmentBookingPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.schedule),
                      title: Text('My Appointments'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyBookingsPage()),
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
          } else if (index == 0) {
            // Bookings tab
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MerchantPage(userName: 'userName',)),
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
    );
  }
}