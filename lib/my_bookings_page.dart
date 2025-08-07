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

  Future<void> _deleteBooking(String bookingId) async {
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
        'http://api.touchmeapp.com/api/bookings/$bookingId',
      );
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings();
      } else {
        throw Exception(
          'Failed to delete booking. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(String bookingId, String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Booking'),
          content: Text('Are you sure you want to delete $serviceName?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBooking(bookingId);
              },
            ),
          ],
        );
      },
    );
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
                          vertical: 10,
                          horizontal: 16,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.customerName.isEmpty
                                    ? 'N/A'
                                    : booking.customerName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${booking.date} | ${booking.time}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          booking.status == 'Upcoming'
                                              ? Colors.orange[100]
                                              : booking.status == 'Completed'
                                              ? Colors.green[100]
                                              : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
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
                                  ),
                                  Row(
                                    children: [
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
                                            _updateBookingStatus(
                                              booking.id,
                                              newStatus,
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        onPressed:
                                            () => _showDeleteConfirmationDialog(
                                              booking.id,
                                              booking.serviceName,
                                            ),
                                        tooltip: 'Delete Booking',
                                      ),
                                    ],
                                  ),
                                ],
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
