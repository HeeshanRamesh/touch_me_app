import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart';
import 'package:touch_me/saloon_review_screen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String? _selectedTimeSlot = '10:30 AM';
  List<Booking> _bookings = [];
  final _storage = const FlutterSecureStorage();
  bool _isLoadingBookings = false;

  final List<Map<String, dynamic>> _timeSlots = [
    {'time': '10:00 AM', 'availability': '25%'},
    {'time': '10:30 AM', 'availability': ''},
    {'time': '11:00 AM', 'availability': '25%'},
    {'time': '11:30 AM', 'availability': ''},
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  void _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
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
        _isLoadingBookings = false;
      });
      return;
    }

    try {
      final fetchedBookings = await fetchMerchantBookings(token);
      setState(() {
        _bookings = fetchedBookings;
        _isLoadingBookings = false;
      });
      print('Loaded ${_bookings.length} bookings'); // Debug print
    } catch (e) {
      print('Error loading bookings: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoadingBookings = false;
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

  // Helper function to format DateTime to 'yyyy-MM-dd'
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245),
        title: const Text(
          'Book an Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Showing Time Slots with Promotions Only'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF6A1B9A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Promotions',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          // Add refresh button
          // IconButton(
          //   icon: const Icon(Icons.refresh, color: Colors.black),
          //   onPressed: _loadBookings,
          // ),
        ],
      ),
      body: _isLoadingBookings
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6A1B9A)),
                  SizedBox(height: 16),
                  Text('Loading appointments...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        
                        // Show booking dialog for any booking on this date
                        final booking = _getBookingForDate(selectedDay);
                        if (booking != null) {
                          _showBookingDialog(booking);
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: true,
                        outsideTextStyle: const TextStyle(color: Colors.grey),
                        defaultTextStyle: const TextStyle(color: Colors.black),
                        weekendTextStyle: const TextStyle(color: Colors.black),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF6A1B9A),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(color: Colors.white),
                        todayDecoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(color: Colors.black),
                        markersMaxCount: 3,
                        markerDecoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        // Add different marker styles for different booking statuses
                        markerSize: 6.0,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: const Icon(
                          Icons.arrow_left,
                          color: Colors.black,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.arrow_right,
                          color: Colors.black,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.black),
                        weekendStyle: TextStyle(color: Colors.black),
                      ),
                      // Updated event loader to show all bookings
                      eventLoader: (day) {
                        return _getBookingsForDate(day);
                      },
                      // Custom marker builder to show different colors for different statuses
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          if (events.isNotEmpty) {
                            final bookingsForDay = _getBookingsForDate(day);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: bookingsForDay.map((booking) {
                                Color markerColor;
                                switch (booking.status.toLowerCase()) {
                                  case 'completed':
                                    markerColor = Colors.green;
                                    break;
                                  case 'upcoming':
                                    markerColor = Colors.blue;
                                    break;
                                  case 'cancelled':
                                    markerColor = Colors.red;
                                    break;
                                  default:
                                    markerColor = Colors.orange;
                                }
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: markerColor,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList(),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  
                  // Show existing bookings list
                  if (_bookings.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          return _buildBookingCard(booking);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Time slots selection
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _timeSlots.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _timeSlots.length) {
                          return GestureDetector(
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                final formatted = pickedTime.format(context);
                                setState(() {
                                  _selectedTimeSlot = formatted;
                                });
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.purple),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Color(0xFF6A1B9A),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Other time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final slot = _timeSlots[index];
                        final isSelected = _selectedTimeSlot == slot['time'];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text("Confirm Time Slot"),
                                content: Text(
                                  "Book appointment at ${slot['time']} with Kamal Dunusinghe?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedTimeSlot = slot['time'];
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(color: Color(0xFF6A1B9A)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6A1B9A)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  slot['time'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (slot['availability'].isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    slot['availability'],
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Service details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Haircut',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: const [
                                  Text(
                                    '25,000 LKR',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '15,000 LKR',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '10.30 – 11.15 AM',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(
                                  'assets/images/stylist_avatar.png',
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF6A1B9A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Kamal Dunusinghe',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Additional options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.add, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Add another service',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.edit_note, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Leave a Note (Optional)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Book button
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '15,000 LKR · 45 Minutes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            final token = await _getToken();
                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No authentication token found. Please log in.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            try {
                              final url = Uri.parse(
                                'http://api.touchmeapp.com/api/bookings',
                              );
                              final response = await http.post(
                                url,
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode({
                                  'serviceName': 'Haircut',
                                  'customerName': 'Kamal Dunusinghe',
                                  'date': _selectedDay != null
                                      ? _formatDate(_selectedDay!)
                                      : _formatDate(DateTime.now()),
                                  'time': _selectedTimeSlot,
                                  'status': 'Upcoming',
                                }),
                              );
                              if (response.statusCode == 201) {
                                final newBooking = Booking(
                                  id: jsonDecode(response.body)['id'],
                                  serviceName: 'Haircut',
                                  customerName: 'Kamal Dunusinghe',
                                  date: _selectedDay != null
                                      ? _formatDate(_selectedDay!)
                                      : _formatDate(DateTime.now()),
                                  time: _selectedTimeSlot!,
                                  status: 'Upcoming',
                                );
                                setState(() {
                                  _bookings.add(newBooking);
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SaloonReviewScreen(),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Appointment booked successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _loadBookings();
                              } else {
                                throw Exception(
                                  'Failed to create booking: ${response.body}',
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error booking appointment: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // Build booking card widget
  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    switch (booking.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'upcoming':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () => _showBookingDialog(booking),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.serviceName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              booking.customerName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Service:', booking.serviceName),
            _buildDetailRow('Customer:', booking.customerName),
            _buildDetailRow('Date:', booking.date),
            _buildDetailRow('Time:', booking.time),
            _buildDetailRow('Status:', booking.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Updated method to get all bookings for a date (not just completed ones)
  List<Booking> _getBookingsForDate(DateTime date) {
    return _bookings.where((booking) {
      try {
        return isSameDay(DateTime.parse(booking.date), date);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Updated method to get any booking for a date (not just completed ones)
  Booking? _getBookingForDate(DateTime date) {
    try {
      return _bookings.firstWhere(
        (booking) => isSameDay(DateTime.parse(booking.date), date),
      );
    } catch (e) {
      return null;
    }
  }

  // Keep the old method for backward compatibility
  bool _hasCompletedBookingOnDate(DateTime date) {
    return _bookings.any(
      (booking) =>
          isSameDay(DateTime.parse(booking.date), date) &&
          booking.status == 'Completed',
    );
  }
}