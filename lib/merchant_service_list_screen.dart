import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:touch_me/payment_page.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import '../models/service.dart';
import '../models/gift.dart';
import '../models/review.dart';
import '../models/booking.dart';
import '../services/services.dart';
import '../services/bookings.dart';
import '../services/reviews.dart';
import '../services/gift_cards.dart';
import '../reviews_tab.dart';

class MerchantServiceListScreen extends StatefulWidget {
  final String merchantId;
  final String outletName;
  final String token;
  final String customerId;

  const MerchantServiceListScreen({
    super.key,
    required this.merchantId,
    required this.outletName,
    required this.token,
    required this.customerId,
  });

  @override
  State<MerchantServiceListScreen> createState() =>
      _MerchantServiceListScreenState();
}

class _MerchantServiceListScreenState extends State<MerchantServiceListScreen> {
  late Future<List<Service>> _futureServices;
  late Future<List<Review>> _futureReviews;
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureServices = fetchServicesByMerchant(widget.merchantId, widget.token);
    _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    _futureBookings = fetchCustomerBookings(widget.token);
  }

  void refreshReviews() {
    setState(() {
      _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    });
  }

  void refreshBookings() {
    setState(() {
      _futureBookings = fetchCustomerBookings(widget.token);
    });
  }

  Future<void> launchPaymentURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!uri.isAbsolute || !['http', 'https'].contains(uri.scheme)) {
        throw 'Invalid URL: $url';
      }

      print('🌐 Attempting to launch URL: $url');
      if (await canLaunchUrl(uri)) {
        print('✅ URL can be launched');
        bool success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!success) {
          print('⚠️ externalApplication failed, trying platformDefault');
          success = await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
        if (success) {
          print('🚀 URL launched successfully');
          return;
        }
      }

      print('⚠️ URL launch failed, falling back to WebView');
      try {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WebViewPage(url: url)),
        );
        print('🌐 WebView page closed');
      } catch (e) {
        print('❌ Error navigating to WebView: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening WebView: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching payment URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.outletName),
          backgroundColor: const Color(0xFF6A1B9A),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(text: 'Services'),
              Tab(text: 'Reviews'),
              Tab(text: 'Portfolio'),
              Tab(text: 'Details'),
              Tab(text: 'My Bookings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildServicesTab(),
            ReviewsTab(
              merchantId: widget.merchantId,
              token: widget.token,
              onReviewSubmitted: refreshReviews,
              futureReviews: _futureReviews,
            ),
            const Center(child: Text('Portfolio (Coming Soon)')),
            _buildDetailsTab(),
            _buildMyBookingsTab(),
          ],
        ),
      ),
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

        const String location = '12/2A, Kesbewa, Piliyandala';
        const int reviewCount = 226;
        const double rating = 5.0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://media.istockphoto.com/id/469090778/photo/interior-of-empty-modern-hair-and-beauty-salon.jpg?s=612x612&w=0&k=20&c=pGrPWP2B83obfEA8unZrPm9oCLEuSLv3tqeK0zA4bEc=',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.outletName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Save Up to 10% ✂️',
                          style: TextStyle(color: Colors.purple, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '$rating',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$reviewCount Reviews',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for Service',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text(
                  'Popular Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length >= 3 ? 3 : services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceCardWidget(
                    service: service,
                    customerId: widget.customerId,
                    merchantId: widget.merchantId,
                    token: widget.token,
                    launchPaymentURL: launchPaymentURL,
                    onBookingSuccess: refreshBookings,
                  );
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text(
                  'Other Services',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length > 3 ? services.length - 3 : 0,
                itemBuilder: (context, index) {
                  final service = services[index + 3];
                  return ServiceCardWidget(
                    service: service,
                    customerId: widget.customerId,
                    merchantId: widget.merchantId,
                    token: widget.token,
                    launchPaymentURL: launchPaymentURL,
                    onBookingSuccess: refreshBookings,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Salon Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Address: 12/2A, Kesbewa, Piliyandala',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text('Contact: +94 11 261 2345', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'Opening Hours: 9:00 AM - 6:00 PM',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'About: We are a premium salon offering top-notch beauty and haircare services.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookingsTab() {
    return FutureBuilder<List<Booking>>(
      future: _futureBookings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading bookings: ${snapshot.error}'),
          );
        }

        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return const Center(
            child: Text(
              'No bookings found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            Color statusColor;
            switch (booking.status.toLowerCase()) {
              case 'upcoming':
                statusColor = Colors.blue;
                break;
              case 'completed':
                statusColor = Colors.green;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12.0),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(
                    _getStatusIcon(booking.status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  booking.serviceName,
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
                      'Date: ${booking.date}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Time: ${booking.time}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.status,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Customer: ${booking.customerName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on ${booking.serviceName}')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}

class ServiceCardWidget extends StatelessWidget {
  final Service service;
  final String customerId;
  final String merchantId;
  final String token;
  final Future<void> Function(String, BuildContext) launchPaymentURL;
  final VoidCallback onBookingSuccess;

  const ServiceCardWidget({
    super.key,
    required this.service,
    required this.customerId,
    required this.merchantId,
    required this.token,
    required this.launchPaymentURL,
    required this.onBookingSuccess,
  });

  Future<void> _showBookingDialog(BuildContext context) async {
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
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        } catch (e) {
                          print("Error picking date: $e");
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedDate == null || selectedTime == null
                      ? null
                      : () async {
                          final formattedDate =
                              '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                          final formattedTime =
                              '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                          final shortId = DateTime.now()
                              .millisecondsSinceEpoch
                              .toString()
                              .substring(5);
                          final orderId = 'ORD${service.id}$shortId'.substring(0, 21);

                          try {
                            print('🌐 Initiating payment for order: $orderId');
                            final paymentResponse = await _initiateOnePayPayment(
                              amount: service.price.toDouble(),
                              orderId: orderId,
                              customerId: customerId,
                              returnUrl: 'http://api.touchmeapp.com/api/payments/payment-callback',
                              token: token,
                            );

                            if (paymentResponse['status'] == 'success' &&
                                paymentResponse['paymentUrl'] != null) {
                              final paymentUrl = paymentResponse['paymentUrl'];
                              final ipgTransactionId = paymentResponse['ipg_transaction_id'];

                              print('🌐 Booking service...');
                              final bookingResponse = await bookService(
                                customerId: customerId,
                                merchantId: merchantId,
                                saloonServiceId: service.id,
                                date: formattedDate,
                                time: formattedTime,
                                token: token,
                                ipgTransactionId: ipgTransactionId,
                              );

                              print('✅ Booking Response: ${jsonEncode(bookingResponse)}');
                              if (bookingResponse['success'] == true) {
                                // Close the dialog first
                                Navigator.pop(context);
                                
                                // Launch payment URL
                                await launchPaymentURL(paymentUrl, context);
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Booking created! Please complete payment. 🎉'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                
                                // Refresh bookings
                                onBookingSuccess();
                              } else {
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
                            print('❌ Error during booking: $e');
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

  Future<Map<String, dynamic>> _initiateOnePayPayment({
    required double amount,
    required String orderId,
    required String customerId,
    required String returnUrl,
    required String token,
  }) async {
    try {
      print('📤 Initiating OnePay Payment for amount: $amount, order: $orderId');
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

      print('📦 OnePay Response Status: ${response.statusCode}');
      print('📦 OnePay Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['paymentUrl'] != null) {
          return {
            'status': 'success',
            'paymentUrl': data['paymentUrl'],
            'ipg_transaction_id': data['ipg_transaction_id'] ?? '',
          };
        }
        return {
          'status': 'failure',
          'message': 'Missing expected payment data',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'status': 'failure',
          'message': error['message'] ?? 'Payment failed',
        };
      }
    } catch (e) {
      print('❌ Exception during OnePay payment: $e');
      return {'status': 'failure', 'message': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          service.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          service.serviceDescription ?? 'No description available',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rs ${service.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () => _showBookingDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(80, 36),
              ),
              child: const Text(
                'Pay & Book',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
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
    final url = Uri.parse('http://api.touchmeapp.com/api/purchased-gift-cards/buy');
    try {
      print('🌐 Buying gift card: ${gc.id} for merchant: $merchantId');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'giftCardId': gc.id, 'merchantId': merchantId}),
      );

      print('📦 Gift Card Response Status: ${response.statusCode}');
      print('📦 Gift Card Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to buy gift card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error buying gift card: $e');
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
          return Center(
            child: Text('Failed to load gift cards: ${snapshot.error}'),
          );
        }
        final giftCards = snapshot.data ?? [];
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

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print('🌐 Initializing WebView for URL: ${widget.url}');
    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              print('🌐 WebView started loading: $url');
              setState(() => isLoading = true);
            },
            onPageFinished: (url) {
              print('🌐 WebView finished loading: $url');
              setState(() => isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              print(
                '❌ WebView error: ${error.description} (code: ${error.errorCode})',
              );
              setState(() {
                isLoading = false;
                errorMessage = error.description;
              });
            },
          ),
        );

      controller.loadRequest(Uri.parse(widget.url)).catchError((e) {
        print('❌ Error loading WebView URL: $e');
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      });

      if (Platform.isAndroid) {
        controller.setBackgroundColor(Colors.white);
      }
    } catch (e) {
      print('❌ Error initializing WebView: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: Stack(
        children: [
          if (errorMessage != null)
            Center(
              child: Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          else
            WebViewWidget(controller: controller),
          if (isLoading && errorMessage == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}