import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  Future<List<Booking>>? _futureBookings;
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
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
    setState(() {
      _futureBookings = fetchMerchantBookings(token);
    });
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
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
      final url = Uri.parse(
        'http://api.touchmeapp.com/api/bookings/$bookingId/status',
      );
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the bookings list
        _loadBookings();
      } else {
        throw Exception(
          'Failed to update booking status. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body:
          _futureBookings == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Booking>>(
                future: _futureBookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return const Center(child: Text('No bookings found.'));
                  }
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          title: Text(
                            '${booking.serviceName} - ${booking.customerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${booking.date} | ${booking.time}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                booking.status,
                                style: TextStyle(
                                  color:
                                      booking.status == 'Upcoming'
                                          ? Colors.orange
                                          : booking.status == 'Completed'
                                          ? Colors.green
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: booking.status,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Upcoming',
                                    child: Text('Upcoming'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Completed',
                                    child: Text('Completed'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cancelled',
                                    child: Text('Cancelled'),
                                  ),
                                ],
                                onChanged: (newStatus) {
                                  if (newStatus != null &&
                                      newStatus != booking.status) {
                                    _updateBookingStatus(booking.id, newStatus);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
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
