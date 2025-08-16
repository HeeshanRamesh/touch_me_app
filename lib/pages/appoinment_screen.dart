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
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '${allDayBookings.length} ${allDayBookings.length == 1 ? 'Appointment' : 'Appointments'}',
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status summary
                      if (confirmedDayBookings.isNotEmpty ||
                          cancelledDayBookings.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              if (confirmedDayBookings.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${confirmedDayBookings.length} Confirmed',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (confirmedDayBookings.isNotEmpty &&
                                  cancelledDayBookings.isNotEmpty)
                                SizedBox(width: 8),
                              if (cancelledDayBookings.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${cancelledDayBookings.length} Cancelled',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(height: 12),
                      // Bookings list
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: allDayBookings.length,
                          itemBuilder: (context, index) {
                            final booking = allDayBookings[index];
                            return _buildCompactBookingCard(booking);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildCompactBookingCard(Booking booking) {
    final bool isCancelled = booking.status.toLowerCase() == 'cancelled';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCancelled
                  ? Colors.red.withOpacity(0.3)
                  : Colors.purple.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.id,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCancelled ? Colors.grey[600] : Colors.black,
                      decoration:
                          isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isCancelled
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: isCancelled ? Colors.red[700] : Colors.green[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCancelled ? Colors.grey[600] : Colors.black,
                      decoration:
                          isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isCancelled ? Colors.grey[400] : Colors.grey[600],
                ),
                SizedBox(width: 4),
                Text(
                  booking.time,
                  style: TextStyle(
                    color: isCancelled ? Colors.grey[500] : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(width: 16),
                Icon(
                  Icons.person,
                  size: 16,
                  color: isCancelled ? Colors.grey[400] : Colors.grey[600],
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.customerName,
                    style: TextStyle(
                      color: isCancelled ? Colors.grey[500] : Colors.grey[700],
                      fontSize: 14,
                      decoration:
                          isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showFullBookingDetails(booking);
                    },
                    icon: Icon(Icons.info_outline, size: 16),
                    label: Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isCancelled ? Colors.grey : Colors.purple,
                      side: BorderSide(
                        color:
                            isCancelled
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.purple.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        isCancelled
                            ? null
                            : () {
                              Navigator.pop(context);
                              _showCancelDialog(booking);
                            },
                    icon: Icon(Icons.cancel_outlined, size: 16),
                    label: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCancelled ? Colors.grey : Colors.red,
                      side: BorderSide(
                        color:
                            isCancelled
                                ? Colors.grey.withOpacity(0.3)
                                : Colors.red.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullBookingDetails(Booking booking) {
    final bool isCancelled = booking.status.toLowerCase() == 'cancelled';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  isCancelled ? Icons.event_busy : Icons.event_available,
                  color: isCancelled ? Colors.red : Colors.purple,
                ),
                SizedBox(width: 8),
                Text('Booking Details'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Service:', booking.serviceName, isCancelled),
                  _buildDetailRow(
                    'Customer:',
                    booking.customerName,
                    isCancelled,
                  ),
                  _buildDetailRow(
                    'Date:',
                    _formatDate(booking.date),
                    isCancelled,
                  ),
                  _buildDetailRow('Time:', booking.time, isCancelled),
                  _buildDetailRow('Status:', booking.status, isCancelled),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: isCancelled ? Colors.grey : Colors.purple,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Cancel Appointment'),
              ],
            ),
            content: Text(
              'Are you sure you want to cancel this appointment?\n\nService: ${booking.serviceName}\nDate: ${_formatDate(booking.date)}\nTime: ${booking.time}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Keep Appointment',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelBooking(booking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Cancel Appointment',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, [
    bool isCancelled = false,
  ]) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isCancelled ? Colors.grey[600] : Colors.black87,
                decoration: isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    // TODO: Implement the cancel booking API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cancel booking functionality to be implemented'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Refresh bookings after cancel attempt
    _loadAllBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245),
        title: const Text(
          'Confirm Appointments',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Loading indicator
            if (isLoading)
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Loading appointments...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            // Calendar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TableCalendar<Booking>(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getBookingsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  // Show appointment details if there are any for this day
                  if (_hasAppointments(selectedDay)) {
                    _showAppointmentDetails(selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders<Booking>(
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
                                  color: Colors.orange,
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
                            if (confirmedCount > 0 && cancelledCount > 0)
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
                        backgroundColor = Colors.orange.withOpacity(0.1);
                        borderColor = Colors.orange.withOpacity(0.5);
                        textColor = Colors.orange[700]!;
                      } else if (hasConfirmed) {
                        // Only confirmed appointments
                        backgroundColor = Colors.purple.withOpacity(0.1);
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
                          border: Border.all(color: borderColor, width: 1),
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
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.black),
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
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
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
}
