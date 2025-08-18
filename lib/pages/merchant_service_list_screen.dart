import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:touch_me/pages/booking_confirm_page.dart';
import 'package:touch_me/pages/reviews_tab.dart';
import 'dart:convert';
import '../models/service.dart';
import '../models/review.dart';
import '../models/booking.dart';
import '../models/gift.dart';
import '../models/merchant.dart';
import '../services/services.dart';
import '../services/bookings.dart';
import '../services/reviews.dart';
import '../services/gift_cards.dart';
import '../services/merchant_service.dart';

class MerchantServiceListScreen extends StatefulWidget {
  final String merchantId;
  final String outletName;
  final String token;
  final String customerId;
  final String profileImageUrl;

  const MerchantServiceListScreen({
    super.key,
    required this.merchantId,
    required this.outletName,
    required this.token,
    required this.customerId,
    required this.profileImageUrl,
  });

  @override
  State<MerchantServiceListScreen> createState() =>
      _MerchantServiceListScreenState();
}

class _MerchantServiceListScreenState extends State<MerchantServiceListScreen> {
  late Future<List<Service>> _futureServices;
  late Future<List<Review>> _futureReviews;
  late Future<List<Booking>> _futureBookings;
  late Future<Merchant?> _futureMerchant;
  int _selectedIndex = 1; // Default to Service tab

  @override
  void initState() {
    super.initState();
    print(
      'DEBUG: Initializing MerchantServiceListScreen for merchant ${widget.merchantId}',
    );
    _futureServices = fetchServicesByMerchant(widget.merchantId, widget.token);
    _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    _futureBookings = fetchCustomerBookings(widget.token);
    _futureMerchant = _fetchMerchantDetails();
  }

  // Fetch merchant details to get the address
  Future<Merchant?> _fetchMerchantDetails() async {
    try {
      print('DEBUG: Fetching merchant details for ID: ${widget.merchantId}');
      final merchants = await fetchMerchants(widget.token);
      return merchants.firstWhere(
        (merchant) => merchant.id == widget.merchantId,
        orElse: () => throw Exception('Merchant not found'),
      );
    } catch (e) {
      print('DEBUG: Error fetching merchant details: $e');
      return null;
    }
  }

  void refreshReviews() {
    print('DEBUG: Refreshing reviews');
    setState(() {
      _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    });
  }

  void refreshBookings() {
    print('DEBUG: Refreshing bookings');
    setState(() {
      _futureBookings = fetchCustomerBookings(widget.token);
    });
  }

  // Helper method to calculate review statistics
  Map<String, dynamic> _calculateReviewStats(List<Review> reviews) {
    if (reviews.isEmpty) {
      return {"average": 0.0, "count": 0};
    }

    double totalRating = 0.0;
    int validReviews = 0;

    for (final review in reviews) {
      if (review.rating > 0 && review.rating <= 5) {
        totalRating += review.rating;
        validReviews++;
      }
    }

    double averageRating = validReviews > 0 ? totalRating / validReviews : 0.0;

    return {"average": averageRating, "count": validReviews};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.outletName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 4,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change back button color to white
        ),
      ),
      body: Column(
        children: [
          _buildSalonProfileHeader(),
          _buildCustomTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildAboutTab(),
                _buildServicesTab(),
                ReviewsTab(
                  merchantId: widget.merchantId,
                  token: widget.token,
                  onReviewSubmitted: refreshReviews,
                  futureReviews: _futureReviews,
                ),
                _buildContactTab(),
                GiftCardsTab(
                  merchantId: widget.merchantId,
                  token: widget.token,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------- Profile Header with Dynamic Address and Real-time Reviews --------
  Widget _buildSalonProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage:
                widget.profileImageUrl.isNotEmpty
                    ? NetworkImage(widget.profileImageUrl)
                    : const NetworkImage(
                      'https://media.istockphoto.com/id/469090778/photo/interior-of-empty-modern-hair-and-beauty-salon.jpg?s=612x612&w=0&k=20&c=pGrPWP2B83obfEA8unZrPm9oCLEuSLv3tqeK0zA4bEc=',
                    ),
            backgroundColor: Colors.grey[200],
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(height: 14),
          Text(
            widget.outletName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Dynamic address display
          FutureBuilder<Merchant?>(
            future: _futureMerchant,
            builder: (context, snapshot) {
              String displayAddress = 'Loading address...';

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  displayAddress = snapshot.data!.address;
                } else {
                  displayAddress = 'Address not available';
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 17,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      displayAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 7),
          // Dynamic review statistics
          FutureBuilder<List<Review>>(
            future: _futureReviews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading reviews...',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                );
              }

              final reviews = snapshot.data ?? [];
              final stats = _calculateReviewStats(reviews);
              final averageRating = stats["average"] as double;
              final reviewCount = stats["count"] as int;

              // Show default values if no reviews
              final displayRating = reviewCount > 0 ? averageRating : 0.0;
              final displayCount = reviewCount;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 19,
                    color: displayCount > 0 ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    displayCount > 0
                        ? displayRating.toStringAsFixed(1)
                        : 'No ratings',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (displayCount > 0) ...[
                    Text(
                      ' ($displayCount review${displayCount != 1 ? 's' : ''})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // -------- Custom Tab Bar --------
  Widget _buildCustomTabBar() {
    final tabs = [
      {'icon': Icons.apartment, 'label': 'About'},
      {'icon': Icons.cut, 'label': 'Service'},
      {'icon': Icons.chat_bubble_outline, 'label': 'Review'},
      {'icon': Icons.call, 'label': 'Contact'},
      {'icon': Icons.card_giftcard, 'label': 'Gift Cards'},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black12, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          final tab = tabs[index];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                setState(() => _selectedIndex = index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? Colors.purple : Colors.black54,
                      size: isSelected ? 26 : 22,
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.purple : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: isSelected ? 15 : 13.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ----------- Tab Contents ------------

  Widget _buildAboutTab() {
    return FutureBuilder<Merchant?>(
      future: _futureMerchant,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to our premium salon! We offer top-notch beauty and haircare services with a focus on customer satisfaction.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      snapshot.hasData && snapshot.data != null
                          ? snapshot.data!.address
                          : 'Address not available',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    return FutureBuilder<List<Service>>(
      future: _futureServices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return const Center(
            child: Text(
              'No services available for this merchant.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(service.image),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          service.serviceName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rs ${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () => _showBookingDialog(context, service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(100, 36),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return FutureBuilder<Merchant?>(
      future: _futureMerchant,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Address Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.purple, size: 20),
                  const Text(
                    'Address: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ), // Indent the address
                child: Text(
                  snapshot.hasData && snapshot.data != null
                      ? snapshot.data!.address ?? 'Address not available'
                      : 'Address not available',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 16),
              // Phone Number Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.phone, color: Colors.purple, size: 20),
                  const Text(
                    'Phone: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Indent the phone
                child: Text(
                  snapshot.hasData && snapshot.data != null
                      ? snapshot.data!.outletPhone ?? 'Not available'
                      : 'Not available',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 12),
              // Email Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.email, color: Colors.purple, size: 20),
                  const Text(
                    'Email: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Indent the email
                child: Text(
                  snapshot.hasData && snapshot.data != null
                      ? snapshot.data!.outletEmail ?? 'Not available'
                      : 'Not available',
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---- Book Service with Success Popup ----
  Future<void> _showBookingDialog(BuildContext context, Service service) async {
    print('DEBUG: Opening booking dialog for service: ${service.serviceName}');
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Book ${service.serviceName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Select Date'),
                      trailing: Text(
                        selectedDate != null
                            ? '${selectedDate!.toLocal()}'.split(' ')[0]
                            : 'Select',
                      ),
                      onTap: () async {
                        try {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2026),
                          );
                          if (pickedDate != null) {
                            print('DEBUG: Selected date: $pickedDate');
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        } catch (e) {
                          print('DEBUG: Error selecting date: $e');
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Select Time'),
                      trailing: Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Select',
                      ),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          print('DEBUG: Selected time: $pickedTime');
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Amount to Pay: Rs ${service.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('DEBUG: Booking cancelled');
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      selectedDate == null || selectedTime == null
                          ? null
                          : () async {
                            print('DEBUG: Processing booking...');
                            final formattedDate =
                                '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                            final formattedTime =
                                '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                            final shortId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString()
                                .substring(5);
                            final baseOrderId = 'ORD${service.id}$shortId';
                            final orderId =
                                baseOrderId.length <= 21
                                    ? baseOrderId
                                    : baseOrderId.substring(0, 21);

                            print('DEBUG: Order ID: $orderId');
                            print(
                              'DEBUG: Booking details - Date: $formattedDate, Time: $formattedTime',
                            );

                            try {
                              print('DEBUG: Initiating payment...');
                              final paymentResponse = await _initiateOnePayPayment(
                                amount: service.price.toDouble(),
                                orderId: orderId,
                                customerId: widget.customerId,
                                returnUrl:
                                    'http://api.touchmeapp.com/api/payments/payment-callback',
                                token: widget.token,
                              );

                              print(
                                'DEBUG: Payment response: $paymentResponse',
                              );

                              if (paymentResponse['status'] == 'success' &&
                                  paymentResponse['paymentUrl'] != null) {
                                print(
                                  'DEBUG: Payment successful, creating booking...',
                                );
                                final bookingResponse = await bookService(
                                  customerId: widget.customerId,
                                  merchantId: widget.merchantId,
                                  saloonServiceId: service.id,
                                  date: formattedDate,
                                  time: formattedTime,
                                  token: widget.token,
                                  ipgTransactionId:
                                      paymentResponse['ipg_transaction_id'],
                                );

                                print(
                                  'DEBUG: Booking response: $bookingResponse',
                                );

                                if (bookingResponse['success'] == true) {
                                  Navigator.pop(
                                    context,
                                  ); // Close the booking dialog

                                  // Extract booking ID from the nested booking object
                                  String bookingId = 'N/A';
                                  if (bookingResponse.containsKey('booking') &&
                                      bookingResponse['booking'] != null &&
                                      bookingResponse['booking'].containsKey(
                                        'id',
                                      )) {
                                    bookingId =
                                        bookingResponse['booking']['id']
                                            ?.toString() ??
                                        'N/A';
                                  }

                                  print(
                                    'DEBUG: Booking successful! ID: $bookingId',
                                  );

                                  // Show success popup before navigating
                                  await _showBookingSuccessPopup(
                                    context,
                                    bookingId,
                                    service,
                                    formattedDate,
                                    formattedTime,
                                  );

                                  refreshBookings();
                                } else {
                                  print(
                                    'DEBUG: Booking failed: ${bookingResponse['message']}',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Booking failed: ${bookingResponse['message'] ?? 'Unknown error'}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                print(
                                  'DEBUG: Payment initiation failed: ${paymentResponse['message']}',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Payment initiation failed: ${paymentResponse['message'] ?? 'Unknown error'}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              print('DEBUG: Booking error: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text(
                    'Pay & Book',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // New method to show booking success popup
  Future<void> _showBookingSuccessPopup(
    BuildContext context,
    String bookingId,
    Service service,
    String date,
    String time,
  ) async {
    print('DEBUG: Showing booking success popup');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),

                // Success message
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Booking ID: $bookingId',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Important Notes Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Important Notes:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildImportantNote(
                        Icons.access_time,
                        'Please arrive 15 minutes before your appointment',
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),

                      _buildImportantNote(
                        Icons.cancel_outlined,
                        'Cancel at least 24 hours in advance',
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),

                      _buildImportantNote(
                        Icons.sms_outlined,
                        'We\'ll send you a reminder SMS',
                        Colors.green,
                      ),
                      const SizedBox(height: 8),

                      _buildImportantNote(
                        Icons.bookmark_outline,
                        'Please save your booking ID',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print('DEBUG: Navigating to booking confirmation page');
                      Navigator.pop(context); // Close popup

                      // Navigate to booking confirmation page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookingConfirmationPage(
                                bookingId: bookingId,
                                serviceName: service.serviceName,
                                serviceDescription:
                                    'Professional ${service.serviceName.toLowerCase()} service',
                                date: date,
                                time: time,
                                serviceId: service.id,
                                totalAmount: service.price.toDouble(),
                                merchantId: widget.merchantId,
                                customerId: widget.customerId,
                                token: widget.token,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Go to Booking Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build important note items
  Widget _buildImportantNote(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _initiateOnePayPayment({
    required double amount,
    required String orderId,
    required String customerId,
    required String returnUrl,
    required String token,
  }) async {
    print(
      'DEBUG: Initiating OnePay payment with amount: $amount, orderId: $orderId',
    );

    try {
      final response = await http.post(
        Uri.parse('http://api.touchmeapp.com/api/payments/onepay-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount.toStringAsFixed(2),
          'reference': orderId,
          'transactionRedirectUrl': returnUrl,
          'customerFirstName': 'Test',
          'customerLastName': 'User',
          'customerEmail': 'testuser@gmail.com',
          'customerPhoneNumber': '+94770000000',
        }),
      );

      print('DEBUG: Payment API response status: ${response.statusCode}');
      print('DEBUG: Payment API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['paymentUrl'] != null) {
          print('DEBUG: Payment initiation successful');
          return {
            'status': 'success',
            'paymentUrl': data['paymentUrl'],
            'ipg_transaction_id': data['ipg_transaction_id'] ?? '',
          };
        }
        print('DEBUG: Payment data incomplete');
        return {
          'status': 'failure',
          'message': 'Missing expected payment data',
        };
      } else {
        final error = jsonDecode(response.body);
        print('DEBUG: Payment API error: ${error['message']}');
        return {
          'status': 'failure',
          'message': error['message'] ?? 'Payment failed',
        };
      }
    } catch (e) {
      print('DEBUG: Payment exception: $e');
      return {'status': 'failure', 'message': e.toString()};
    }
  }
}

class GiftCardsTab extends StatelessWidget {
  final String merchantId;
  final String token;

  const GiftCardsTab({
    super.key,
    required this.merchantId,
    required this.token,
  });

  Future<void> _buyGiftCard(BuildContext context, GiftCard gc) async {
    print('DEBUG: Attempting to buy gift card: ${gc.giftCardName}');

    final url = Uri.parse(
      'http://api.touchmeapp.com/api/purchased-gift-cards/buy',
    );
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'giftCardId': gc.id, 'merchantId': merchantId}),
      );

      print(
        'DEBUG: Gift card purchase response status: ${response.statusCode}',
      );
      print('DEBUG: Gift card purchase response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print('DEBUG: Gift card purchased successfully');
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Gift Card Purchased!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Gift Card Code:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['code'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Expiry Date: ${data['expiryDate'] != null ? data['expiryDate'].substring(0, 10) : 'N/A'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Value: Rs ${data['value']?.toStringAsFixed(2) ?? 'N/A'}',
                    ),
                    const SizedBox(height: 8),
                    Text('Status: ${data['status'] ?? 'N/A'}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        print('DEBUG: Gift card purchase failed: ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to buy gift card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Gift card purchase exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GiftCard>>(
      future: fetchGiftCardsByMerchant(merchantId, token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('DEBUG: Error loading gift cards: ${snapshot.error}');
          return Center(
            child: Text('Failed to load gift cards: ${snapshot.error}'),
          );
        }
        final giftCards = snapshot.data ?? [];
        print('DEBUG: Loaded ${giftCards.length} gift cards');

        if (giftCards.isEmpty) {
          return const Center(child: Text('No gift cards for this merchant.'));
        }
        return ListView.builder(
          itemCount: giftCards.length,
          itemBuilder: (context, i) {
            final gc = giftCards[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  gc.giftCardName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  gc.giftCardDescription ?? 'No description available',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rs ${gc.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () => _buyGiftCard(context, gc),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
