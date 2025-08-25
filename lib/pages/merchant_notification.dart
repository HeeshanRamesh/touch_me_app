import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:touch_me/models/booking.dart';
import 'package:touch_me/pages/my_bookings_page.dart';

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
    
    // Get stored notification IDs to avoid duplicates
    Set<String> readNotifications = await _getReadNotifications();

    for (var booking in bookings) {
      // Only show notifications for new bookings (created within last 24 hours)
      // and with status 'Pending' or 'Confirmed' (newly booked)
      if ((booking.status == 'Upcoming')) {
        final notificationId = 'new_${booking.id}';
        
        // Skip if notification was already read/dismissed
        if (readNotifications.contains(notificationId)) {
          continue;
        }

        // Check if booking was created recently (within last 24 hours)
        // Note: You might need to add a createdAt field to your Booking model
        // For now, using booking date as a fallback
        final bookingDate = DateTime.parse(booking.date);
        final hoursSinceBooking = now.difference(bookingDate).inHours;
        
        // Show notification if booking is for today or future dates
        if (bookingDate.isAfter(now.subtract(const Duration(hours: 24))) || 
            bookingDate.isAfter(DateTime(now.year, now.month, now.day))) {
          
          newNotifications.add({
            'id': notificationId,
            'title': 'New Booking Received',
            'message':
                'New booking for ${booking.serviceName} with ${booking.customerName} scheduled for ${DateFormat('MMM d, yyyy').format(bookingDate)} at ${booking.time}.',
            'timestamp': DateTime.now().toIso8601String(),
            'type': 'new_booking',
            'bookingId': booking.id,
            'bookingStatus': booking.status,
          });
        }
      }
    }

    // Sort notifications by timestamp (newest first)
    newNotifications.sort(
      (a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])),
    );
    
    return newNotifications;
  }

  Future<Set<String>> _getReadNotifications() async {
    final readNotificationsString = await _storage.read(key: 'read_notifications') ?? '';
    return readNotificationsString.split(',').where((id) => id.isNotEmpty).toSet();
  }

  Future<void> _saveReadNotifications(Set<String> readNotifications) async {
    await _storage.write(key: 'read_notifications', value: readNotifications.join(','));
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    // Get current read notifications
    Set<String> readNotifications = await _getReadNotifications();
    readNotifications.add(notificationId);
    
    // Save to storage
    await _saveReadNotifications(readNotifications);
    
    // Remove from current list
    setState(() {
      notifications.removeWhere((notification) => notification['id'] == notificationId);
    });
  }

  Future<void> _markAllAsRead() async {
    Set<String> readNotifications = await _getReadNotifications();
    for (var notification in notifications) {
      readNotifications.add(notification['id']);
    }
    await _saveReadNotifications(readNotifications);
    
    setState(() {
      notifications.clear();
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
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.purple),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No new bookings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'New booking notifications will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event_available,
                            color: Colors.blue,
                            size: 24,
                          ),
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
                            Text(
                              notification['message'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: notification['bookingStatus'] == 'Confirmed'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    notification['bookingStatus'] ?? 'Pending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: notification['bookingStatus'] == 'Confirmed'
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('MMM d, HH:mm').format(
                                    DateTime.parse(notification['timestamp']),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                          onPressed: () => _markNotificationAsRead(notification['id']),
                        ),
                        onTap: () {
                          // Optionally navigate to booking details
                          Navigator.push(
                          context,
                             MaterialPageRoute(
                               builder: (context) => MyBookingsPage(),
                          //       bookingId: notification['bookingId'],
                          //     ),
                          ),
                           );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}