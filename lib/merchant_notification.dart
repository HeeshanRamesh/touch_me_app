import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:touch_me/models/booking.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authentication token found. Please log in.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final bookings = await fetchMerchantBookings(token);
      final newNotifications = await _generateNotifications(bookings);

      setState(() {
        notifications = newNotifications;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
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

  Future<List<Map<String, dynamic>>> _generateNotifications(
    List<Booking> bookings,
  ) async {
    List<Map<String, dynamic>> newNotifications = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var booking in bookings) {
      final bookingDate = DateTime.parse(booking.date);
      final isToday =
          bookingDate.year == today.year &&
          bookingDate.month == today.month &&
          bookingDate.day == today.day;

      // Check for completed bookings on current date
      if (isToday && booking.status == 'Completed') {
        newNotifications.add({
          'id': 'completed_${booking.id}',
          'title': 'Booking Completed',
          'message':
              'Booking for ${booking.serviceName} with ${booking.customerName} on ${booking.date} at ${booking.time} has been completed.',
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'completed',
          'bookingId': booking.id,
        });
      }

      // Check for new bookings (assuming bookings created within last 24 hours are "new")
      final bookingCreationTime = DateTime.parse(booking.date);
      if (DateTime.now().difference(bookingCreationTime).inHours < 24) {
        newNotifications.add({
          'id': 'new_${booking.id}',
          'title': 'New Booking',
          'message':
              'New booking for ${booking.serviceName} with ${booking.customerName} scheduled for ${booking.date} at ${booking.time}.',
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'new',
          'bookingId': booking.id,
        });
      }
    }

    // Sort notifications by timestamp (newest first)
    newNotifications.sort(
      (a, b) => DateTime.parse(
        b['timestamp'],
      ).compareTo(DateTime.parse(a['timestamp'])),
    );
    return newNotifications;
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    setState(() {
      notifications.removeWhere(
        (notification) => notification['id'] == notificationId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.purple),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(
                child: Text(
                  'No notifications available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        notification['type'] == 'completed'
                            ? Icons.check_circle
                            : Icons.event,
                        color:
                            notification['type'] == 'completed'
                                ? Colors.green
                                : Colors.blue,
                      ),
                      title: Text(
                        notification['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notification['message']),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM d, yyyy HH:mm',
                            ).format(DateTime.parse(notification['timestamp'])),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed:
                            () => _markNotificationAsRead(notification['id']),
                      ),
                      onTap: () {
                        // Optionally navigate to booking details
                        // You can add navigation to a booking details page here
                      },
                    ),
                  );
                },
              ),
    );
  }
}
