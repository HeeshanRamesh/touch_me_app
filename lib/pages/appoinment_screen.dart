import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart'; // Import Booking model

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String? _selectedTimeSlot;
  List<Booking> confirmedBookings = [];
  List<Booking> cancelledBookings = [];
  bool isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadAllBookings();
  }

  Future<String?> _getUserId() async {
    final userId = await _storage.read(key: 'user_id');
    return userId;
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token;
  }

  Future<void> _loadAllBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId != null && token != null) {
        // Load both confirmed and cancelled bookings
        final fetchedConfirmedBookings = await fetchBookings(
          userId,
          token,
          'Confirm',
        );
        final fetchedCancelledBookings = await fetchBookings(
          userId,
          token,
          'Cancelled',
        );

        setState(() {
          confirmedBookings = fetchedConfirmedBookings;
          cancelledBookings = fetchedCancelledBookings;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadConfirmedBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId != null && token != null) {
        final fetchedBookings = await fetchBookings(userId, token, 'Confirm');
        setState(() {
          confirmedBookings = fetchedBookings;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Booking>> fetchBookings(
    String userId,
    String token,
    String status,
  ) async {
    final url = Uri.parse(
      'http://api.touchmeapp.com/api/bookings/customer/$userId?status=$status',
    );

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

      final parsedBookings = bookings.map((b) => Booking.fromJson(b)).toList();
      return parsedBookings;
    } else {
      throw Exception('Failed to fetch $status bookings: ${response.body}');
    }
  }

  // Legacy method for backward compatibility
  Future<List<Booking>> fetchConfirmedBookings(
    String userId,
    String token,
  ) async {
    return fetchBookings(userId, token, 'Confirm');
  }

  // Get confirmed bookings for a specific date
  List<Booking> _getConfirmedBookingsForDay(DateTime day) {
    return confirmedBookings.where((booking) {
      try {
        final bookingDate = DateTime.parse(booking.date);
        return isSameDay(bookingDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get cancelled bookings for a specific date
  List<Booking> _getCancelledBookingsForDay(DateTime day) {
    return cancelledBookings.where((booking) {
      try {
        final bookingDate = DateTime.parse(booking.date);
        return isSameDay(bookingDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get all bookings (confirmed + cancelled) for a specific date
  List<Booking> _getAllBookingsForDay(DateTime day) {
    final confirmed = _getConfirmedBookingsForDay(day);
    final cancelled = _getCancelledBookingsForDay(day);
    return [...confirmed, ...cancelled];
  }

  // Get bookings for a specific date (for calendar event loader)
  List<Booking> _getBookingsForDay(DateTime day) {
    return _getAllBookingsForDay(day);
  }

  // Check if a day has confirmed appointments
  bool _hasConfirmedAppointments(DateTime day) {
    return _getConfirmedBookingsForDay(day).isNotEmpty;
  }

  // Check if a day has cancelled appointments
  bool _hasCancelledAppointments(DateTime day) {
    return _getCancelledBookingsForDay(day).isNotEmpty;
  }

  // Check if a day has any appointments
  bool _hasAppointments(DateTime day) {
    return _getAllBookingsForDay(day).isNotEmpty;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.orange;
      case 'Confirm':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status background color
  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.orange[100]!;
      case 'Confirm':
        return Colors.blue[100]!;
      case 'Completed':
        return Colors.green[100]!;
      case 'Cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  void _showAppointmentDetails(DateTime selectedDay) {
    final allDayBookings = _getAllBookingsForDay(selectedDay);
    final confirmedDayBookings = _getConfirmedBookingsForDay(selectedDay);
    final cancelledDayBookings = _getCancelledBookingsForDay(selectedDay);

    if (allDayBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No appointments found for ${DateFormat('MMM dd, yyyy').format(selectedDay)}',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.purple),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appointments',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'EEEE, MMM dd, yyyy',
                                    ).format(selectedDay),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Badge for total appointments
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${allDayBookings.length} Appointment${allDayBookings.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: Colors.grey[600]),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      // Booking Details List
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: allDayBookings.length,
                          itemBuilder: (context, index) {
                            final booking = allDayBookings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Saloon Name (with icon)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.storefront,
                                          size: 16,
                                          color: Colors.purple[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Saloon: ${booking.saloonName}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.purple[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Outlet Details (New: Phone and Address)
                                    if (booking.saloonName != 'N/A')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Phone: ${booking.outletPhone}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Address: ${booking.outletAddress}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    // Service Name
                                    Text(
                                      booking.serviceName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Customer Name
                                    Text(
                                      booking.customerName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Date & Time
                                    Text(
                                      '${_formatDate(booking.date)} at ${booking.time}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusBackgroundColor(
                                          booking.status,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        booking.status,
                                        style: TextStyle(
                                          color: _getStatusColor(
                                            booking.status,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    // Price
                                    if (booking.price != 'N/A')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Builder(
                                          builder: (context) {
                                            final price =
                                                double.tryParse(
                                                  booking.price,
                                                ) ??
                                                0.0;
                                            final appCost = price * 5 / 100;
                                            final totalPrice = price + appCost;
                                            return Text(
                                              'Total: \Rs.${totalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245),
        title: const Text(
          'Appointments Calendar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Calendar
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                      child: TableCalendar<Booking>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate:
                            (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _showAppointmentDetails(selectedDay);
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: _getBookingsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            if (events.isNotEmpty) {
                              final confirmedCount =
                                  _getConfirmedBookingsForDay(day).length;
                              final cancelledCount =
                                  _getCancelledBookingsForDay(day).length;

                              return Positioned(
                                right: 1,
                                top: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (confirmedCount > 0)
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Colors
                                                  .purple, // Updated to purple for confirmed
                                          shape: BoxShape.circle,
                                        ),
                                        width: 8,
                                        height: 8,
                                        child: Center(
                                          child: Text(
                                            '$confirmedCount',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (confirmedCount > 0 &&
                                        cancelledCount > 0)
                                      SizedBox(width: 2),
                                    if (cancelledCount > 0)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        width: 8,
                                        height: 8,
                                        child: Center(
                                          child: Text(
                                            '$cancelledCount',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 6,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }
                            return null;
                          },
                          defaultBuilder: (context, day, focusedDay) {
                            final hasConfirmed = _hasConfirmedAppointments(day);
                            final hasCancelled = _hasCancelledAppointments(day);

                            if (hasConfirmed || hasCancelled) {
                              Color backgroundColor;
                              Color borderColor;
                              Color textColor;

                              if (hasConfirmed && hasCancelled) {
                                // Mixed state - both confirmed and cancelled
                                backgroundColor = Colors.orange.withOpacity(
                                  0.1,
                                );
                                borderColor = Colors.orange.withOpacity(0.5);
                                textColor = Colors.orange[700]!;
                              } else if (hasConfirmed) {
                                // Only confirmed appointments
                                backgroundColor = Colors.purple.withOpacity(
                                  0.1,
                                );
                                borderColor = Colors.purple.withOpacity(0.3);
                                textColor = Colors.purple[700]!;
                              } else {
                                // Only cancelled appointments
                                backgroundColor = Colors.red.withOpacity(0.1);
                                borderColor = Colors.red.withOpacity(0.3);
                                textColor = Colors.red[700]!;
                              }

                              return Container(
                                margin: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: true,
                          outsideTextStyle: const TextStyle(color: Colors.grey),
                          defaultTextStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF6A1B9A),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(color: Colors.black),
                          markersMaxCount: 2,
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
                          weekdayStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          weekendStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // Info text about calendar highlights
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.purple,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Highlighted dates have appointments. Tap to view details.',
                                    style: TextStyle(
                                      color: Colors.purple[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                // Legend for appointment types
                                _buildLegendItem(Colors.purple, 'Confirmed'),
                                SizedBox(width: 16),
                                _buildLegendItem(Colors.red, 'Cancelled'),
                                SizedBox(width: 16),
                                _buildLegendItem(Colors.orange, 'Mixed'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
