import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart'; // Import Booking model
import 'package:touch_me/saloon_review_screen.dart';

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
  bool isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadConfirmedBookings();
  }

  Future<String?> _getUserId() async {
    final userId = await _storage.read(key: 'user_id');
    return userId;
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token;
  }

  Future<void> _loadConfirmedBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = await _getUserId();
      final token = await _getToken();

      if (userId != null && token != null) {
        final fetchedBookings = await fetchConfirmedBookings(userId, token);
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

  Future<List<Booking>> fetchConfirmedBookings(
    String userId,
    String token,
  ) async {
    final url = Uri.parse(
      'http://api.touchmeapp.com/api/bookings/customer/$userId?status=Confirm',
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
      throw Exception('Failed to fetch confirmed bookings: ${response.body}');
    }
  }

  // Get bookings for a specific date
  List<Booking> _getBookingsForDay(DateTime day) {
    return confirmedBookings.where((booking) {
      try {
        final bookingDate = DateTime.parse(booking.date);
        return isSameDay(bookingDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Check if a day has appointments
  bool _hasAppointments(DateTime day) {
    return _getBookingsForDay(day).isNotEmpty;
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
    final dayBookings = _getBookingsForDay(selectedDay);

    if (dayBookings.isEmpty) {
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
                                '${dayBookings.length} ${dayBookings.length == 1 ? 'Appointment' : 'Appointments'}',
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
                      // Bookings list
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          itemCount: dayBookings.length,
                          itemBuilder: (context, index) {
                            final booking = dayBookings[index];
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
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: Colors.green[700],
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: Colors.green.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     booking.status,
                //     style: TextStyle(
                //       color: Colors.green[700],
                //       fontSize: 11,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  booking.time,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    booking.customerName,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                      foregroundColor: Colors.purple,
                      side: BorderSide(color: Colors.purple.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCancelDialog(booking);
                    },
                    icon: Icon(Icons.cancel_outlined, size: 16),
                    label: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.event_available, color: Colors.purple),
                SizedBox(width: 8),
                Text('Booking Details'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Service:', booking.serviceName),
                  _buildDetailRow('Customer:', booking.customerName),
                  _buildDetailRow('Date:', _formatDate(booking.date)),
                  _buildDetailRow('Time:', booking.time),
                  _buildDetailRow('Status:', booking.status),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(color: Colors.purple)),
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

  Widget _buildDetailRow(String label, String value) {
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
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
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
    _loadConfirmedBookings();
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
        // actions: [
        //   IconButton(
        //     onPressed: _loadConfirmedBookings,
        //     icon: Icon(Icons.refresh, color: Colors.purple),
        //   ),
        //   TextButton(
        //     onPressed: () {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('Showing Time Slots with Promotions Only'),
        //           duration: Duration(seconds: 2),
        //           backgroundColor: Color(0xFF6A1B9A),
        //           behavior: SnackBarBehavior.floating,
        //         ),
        //       );
        //     },
        //     child: const Text(
        //       'Promotions',
        //       style: TextStyle(color: Colors.black, fontSize: 16),
        //     ),
        //   ),
        // ],
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
                      return Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          width: 8,
                          height: 8,
                          child: Center(
                            child: Text(
                              '${events.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    if (_hasAppointments(day)) {
                      return Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: Colors.purple[700],
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
                  markersMaxCount: 1,
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
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple, size: 18),
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
              ),
            ),

            // SizedBox(height: 16),

            // // Time Picker Button
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     children: [
            //       GestureDetector(
            //         onTap: () async {
            //           TimeOfDay? pickedTime = await showTimePicker(
            //             context: context,
            //             initialTime: TimeOfDay.now(),
            //           );
            //           if (pickedTime != null) {
            //             final formatted = pickedTime.format(context);
            //             setState(() {
            //               _selectedTimeSlot = formatted;
            //             });
            //           }
            //         },
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 16, vertical: 12),
            //           decoration: BoxDecoration(
            //             color: Colors.white,
            //             border: Border.all(color: Colors.purple),
            //             borderRadius: BorderRadius.circular(25),
            //           ),
            //           child: const Row(
            //             children: [
            //               Icon(Icons.access_time,
            //                   size: 18, color: Color(0xFF6A1B9A)),
            //               SizedBox(width: 8),
            //               Text(
            //                 "Pick a Time",
            //                 style: TextStyle(
            //                   color: Color(0xFF6A1B9A),
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       const SizedBox(width: 12),
            //       if (_selectedTimeSlot != null)
            //         Text(
            //           'Selected: $_selectedTimeSlot',
            //           style: const TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 16),

            // // Service Info
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.grey[200],
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     padding: const EdgeInsets.all(12),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         // Service Title & Price
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             const Text(
            //               'Haircut',
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 16,
            //               ),
            //             ),
            //             Row(
            //               children: const [
            //                 Text(
            //                   '25,000 LKR',
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.grey,
            //                     decoration: TextDecoration.lineThrough,
            //                   ),
            //                 ),
            //                 SizedBox(width: 6),
            //                 Text(
            //                   '15,000 LKR',
            //                   style: TextStyle(
            //                     fontSize: 14,
            //                     fontWeight: FontWeight.bold,
            //                     color: Color(0xFF6A1B9A),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 4),
            //         const Text(
            //           'Time: 45 minutes',
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //         const SizedBox(height: 12),
            //         Row(
            //           children: [
            //             CircleAvatar(
            //               radius: 18,
            //               backgroundColor: Colors.white,
            //               backgroundImage: const AssetImage(
            //                 'assets/images/stylist_avatar.png',
            //               ),
            //               child: const Icon(
            //                 Icons.person,
            //                 color: Color(0xFF6A1B9A),
            //               ),
            //             ),
            //             const SizedBox(width: 12),
            //             const Text(
            //               'Kamal Dunusinghe',
            //               style: TextStyle(fontSize: 14, color: Colors.black54),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 12),

            // // Optional Actions
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Column(
            //     children: [
            //       Row(
            //         children: const [
            //           Icon(Icons.add, color: Colors.blue),
            //           SizedBox(width: 8),
            //           Text(
            //             'Add another service',
            //             style: TextStyle(
            //               color: Colors.blue,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 12),
            //       Row(
            //         children: const [
            //           Icon(Icons.edit_note, color: Colors.grey),
            //           SizedBox(width: 8),
            //           Text(
            //             'Leave a Note (Optional)',
            //             style: TextStyle(color: Colors.grey),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 16),

            // // Continue Button
            // Column(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(bottom: 8),
            //       child: Text(
            //         '15,000 LKR · 45 Minutes',
            //         style: TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w500,
            //           color: Colors.black,
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16),
            //       child: ElevatedButton(
            //         onPressed: () {
            //           if (_selectedTimeSlot == null) {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(
            //                 content: Text('Please select a time.'),
            //                 backgroundColor: Colors.red,
            //               ),
            //             );
            //             return;
            //           }
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => const SaloonReviewScreen(),
            //             ),
            //           );
            //         },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: const Color(0xFF6A1B9A),
            //           minimumSize: const Size(double.infinity, 50),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(25),
            //           ),
            //         ),
            //         child: const Text(
            //           'Continue',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
