import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart'; // Import Booking model
import 'package:touch_me/merchant_services_screen.dart';
import 'package:touch_me/my_bookings_page.dart';
import 'package:intl/intl.dart'; // For date comparison

class SaloonDashboardScreen extends StatefulWidget {
  final String userName;
  const SaloonDashboardScreen({super.key, required this.userName});

  @override
  State<SaloonDashboardScreen> createState() => _SaloonDashboardScreenState();
}

class _SaloonDashboardScreenState extends State<SaloonDashboardScreen> {
  int _currentIndex = 0;
  List<Booking> todayCompletedBookings = [];
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadTodayCompletedBookings(); // Load completed bookings for today
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _loadTodayCompletedBookings() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authentication token found. Please log in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final fetchedBookings = await fetchMerchantBookings(token);
      setState(() {
        // Filter bookings for today that are completed
        todayCompletedBookings =
            fetchedBookings.where((booking) {
              final bookingDate = DateTime.parse(booking.date);
              final isToday = _isSameDay(bookingDate, DateTime.now());
              return isToday && booking.status == 'Completed';
            }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Booking>> fetchMerchantBookings(String token) async {
    final url = Uri.parse('http://api.touchmeapp.com/api/bookings/my/bookings');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bookings = data['bookings'] as List<dynamic>;
      return bookings.map((b) => Booking.fromJson(b)).toList();
    } else {
      throw Exception('Failed to fetch bookings: ${response.body}');
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
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
                          "Home",
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
              SizedBox(
                height: 300,
                width: 500,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Appointment Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.history, size: 40),
                            SizedBox(height: 10),
                            Text(
                              'No recent activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Visit the calendar section to add some appointments',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              // Your Schedule Card
              SizedBox(
                height: 300,
                width: 500,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Your Schedule',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.bar_chart, size: 40),
                            SizedBox(height: 10),
                            Text(
                              'Your schedule is empty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Make some appointments to get started',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              // Today's Appointments Card
              SizedBox(
                height: 300,
                width: 500,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Today's Appointments",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        todayCompletedBookings.isEmpty
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.history, size: 40),
                                SizedBox(height: 10),
                                Text(
                                  'No appointments today',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Visit the calendar section to add some appointments',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                            : Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: todayCompletedBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = todayCompletedBookings[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Service: ${booking.serviceName}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Customer: ${booking.customerName}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Time: ${booking.time}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${booking.status}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
