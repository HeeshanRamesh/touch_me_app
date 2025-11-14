import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart'; // Import Booking model

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({Key? key}) : super(key: key);
  @override
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  List<Booking> bookings = [];
  List<Booking> selectedBookings = [];
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
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
    try {
      final fetchedBookings = await fetchMerchantBookings(token);
      setState(() {
        bookings = fetchedBookings;
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

  Widget _buildStatusLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: Colors.green.withOpacity(0.6),
                  status: 'Completed',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildLegendItem(
                  color: Colors.yellow.withOpacity(0.7),
                  status: 'Confirmed',
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: Colors.pink.withOpacity(0.6),
                  status: 'Upcoming',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildLegendItem(color: Colors.blue, status: 'Selected'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String status}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back, color: Colors.purple),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book an Appointment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Legend
            _buildStatusLegend(),

            // Calendar Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        focusedDate = DateTime(
                          focusedDate.year,
                          focusedDate.month - 1,
                          1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(focusedDate),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        focusedDate = DateTime(
                          focusedDate.year,
                          focusedDate.month + 1,
                          1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            // Calendar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                            .map(
                              (day) => Container(
                                width: 40,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 300, child: _buildCalendar()),
                ],
              ),
            ),
            // Booking details
            _buildBookingDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDayOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    final firstDayWeekday = firstDayWeekdayOffset(firstDayOfMonth);
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final dayIndex = index - firstDayWeekday;

        if (dayIndex < 0 || dayIndex >= daysInMonth) {
          DateTime date;
          int day;
          if (dayIndex < 0) {
            final prevMonth = DateTime(
              focusedDate.year,
              focusedDate.month - 1,
              0,
            );
            day = prevMonth.day + dayIndex + 1;
            date = DateTime(focusedDate.year, focusedDate.month - 1, day);
          } else {
            day = dayIndex - daysInMonth + 1;
            date = DateTime(focusedDate.year, focusedDate.month + 1, day);
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedBookings = _getBookingsForDate(date);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }

        final day = dayIndex + 1;
        final currentDate = DateTime(focusedDate.year, focusedDate.month, day);
        final hasBooking = _hasBookingOnDate(currentDate);
        final isCompleted = _hasCompletedBookingOnDate(currentDate);
        final isConfirmed = _hasConfirmedBookingOnDate(currentDate);
        final isSelected = _isSameDay(currentDate, selectedDate);
        final isToday = _isSameDay(currentDate, DateTime.now());

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = currentDate;
              selectedBookings = _getBookingsForDate(currentDate);
              if ((isCompleted || isConfirmed) && selectedBookings.isNotEmpty) {
                _showBookingDialog(selectedBookings);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color:
                  isSelected
                      ? Colors.blue
                      : isCompleted
                      ? Colors.green.withOpacity(0.6)
                      : isConfirmed
                      ? Colors.yellow.withOpacity(0.7)
                      : hasBooking
                      ? Colors.pink.withOpacity(0.6)
                      : Colors.transparent,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color:
                      isSelected || isCompleted || isConfirmed || hasBooking
                          ? (isConfirmed ? Colors.black : Colors.white)
                          : isToday
                          ? Colors.blue
                          : Colors.black,
                  fontWeight:
                      isCompleted ||
                              hasBooking ||
                              isSelected ||
                              isToday ||
                              isConfirmed
                          ? FontWeight.bold
                          : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int firstDayWeekdayOffset(DateTime firstDayOfMonth) {
    return firstDayOfMonth.weekday % 7;
  }

  Widget _buildBookingDetails() {
    if (selectedBookings.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'No bookings for this date.',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children:
            selectedBookings.map((booking) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID: ${booking.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Service Name: ${booking.serviceName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Service Price: ${booking.price != 'N/A' ? '\Rs.${booking.price}' : 'N/A'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer Name: ${booking.customerName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    // Added phone number display
                    Text(
                      'Customer Phone: ${booking.customerPhone}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${booking.date}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Time: ${booking.time}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${booking.status}',
                      style: TextStyle(
                        color:
                            booking.status == 'Completed'
                                ? Colors.green
                                : booking.status == 'Confirm'
                                ? Colors.orange
                                : booking.status == 'Upcoming'
                                ? Colors.orange
                                : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  void _showBookingDialog(List<Booking> bookings) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Booking Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    bookings.map((booking) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Booking ID:', booking.id),
                          _buildDetailRow('Service:', booking.serviceName),
                          _buildDetailRow(
                            'Price:',
                            booking.price != 'N/A'
                                ? '\$${booking.price}'
                                : 'N/A',
                          ),
                          _buildDetailRow('Customer:', booking.customerName),
                          _buildDetailRow('Phone:', booking.customerPhone),
                          _buildDetailRow('Date:', booking.date),
                          _buildDetailRow('Time:', booking.time),
                          _buildDetailRow('Status:', booking.status),
                          Divider(),
                        ],
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showCreateBookingDialog() {
    final salonController = TextEditingController();
    final customerController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    final List<String> services = [
      'Hair Cut & Styling - Ladies',
      'Hair Cut & Styling - Gents',
      'Hair Cut & Styling - Kids',
      'Hair Cut & Styling - Adults',
      'Nails',
      'Eyebrow & Eyelashes',
      'Hair Removal',
      'Facials & Skincare',
      'Tattoo & Piercing',
      'Massage',
      'Injectables & Fillers',
      'Makeup',
      'Dressing',
      'Pedicure & Manicure',
      'Bridal',
      'Door step service',
    ];

    String? selectedService;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Book New Appointment'),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedService,
                            decoration: InputDecoration(
                              labelText: 'Service Name',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                services.map((String service) {
                                  return DropdownMenuItem<String>(
                                    value: service,
                                    child: Text(
                                      service,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setDialogState(() {
                                selectedService = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a service';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: salonController,
                            decoration: InputDecoration(
                              labelText: 'Salon Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter salon name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: customerController,
                            decoration: InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Time: ${selectedTime.format(context)}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.access_time),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
                                    if (time != null) {
                                      setDialogState(() {
                                        selectedTime = time;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            selectedService != null) {
                          final token = await _getToken();
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
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
                                'serviceName': selectedService,
                                'salonName': salonController.text,
                                'customerName': customerController.text,
                                'date': DateFormat(
                                  'yyyy-MM-dd',
                                ).format(selectedDate),
                                'time': selectedTime.format(context),
                                'status': 'Upcoming',
                              }),
                            );
                            if (response.statusCode == 201) {
                              final responseData = jsonDecode(response.body);
                              final newBooking = Booking(
                                id: responseData['id'],

                                // ===================================
                                // ✅ ADD THIS LINE
                                // ===================================
                                bookingCode:
                                    responseData['bookingCode'] ?? 'N/A',

                                serviceName: selectedService!,
                                customerName: customerController.text,
                                customerPhone:
                                    responseData['customerPhone'] ?? 'N/A',
                                date: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(selectedDate),
                                time: selectedTime.format(context),
                                status: 'Upcoming',
                                price:
                                    responseData['price']?.toString() ?? 'N/A',
                                saloonName: salonController.text,
                                outletPhone:
                                    responseData['outletPhone'] ?? 'N/A',
                                outletAddress:
                                    responseData['outletAddress'] ?? 'N/A',
                              );
                              setState(() {
                                bookings.add(newBooking);
                                if (_isSameDay(
                                  selectedDate,
                                  DateTime.parse(newBooking.date),
                                )) {
                                  selectedBookings = _getBookingsForDate(
                                    selectedDate,
                                  );
                                }
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Appointment booked successfully!',
                                  ),
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
                        } else if (selectedService == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a service'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text('Book'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  bool _hasBookingOnDate(DateTime date) {
    return bookings.any(
      (booking) => _isSameDay(DateTime.parse(booking.date), date),
    );
  }

  bool _hasCompletedBookingOnDate(DateTime date) {
    return bookings.any(
      (booking) =>
          _isSameDay(DateTime.parse(booking.date), date) &&
          booking.status == 'Completed',
    );
  }

  // New helper method to check for confirmed bookings
  bool _hasConfirmedBookingOnDate(DateTime date) {
    return bookings.any(
      (booking) =>
          _isSameDay(DateTime.parse(booking.date), date) &&
          booking.status == 'Confirm',
    );
  }

  List<Booking> _getBookingsForDate(DateTime date) {
    return bookings
        .where((booking) => _isSameDay(DateTime.parse(booking.date), date))
        .toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
