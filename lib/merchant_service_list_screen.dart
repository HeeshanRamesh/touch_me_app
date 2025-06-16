import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/service.dart';
import '../models/review.dart';
import '../services/services.dart';
import '../services/bookings.dart';
import '../services/reviews.dart';

class MerchantServiceListScreen extends StatefulWidget {
  final String merchantId;
  final String outletName;
  final String token;
  final String customerId;
  final String salonOwnerId;

  const MerchantServiceListScreen({
    super.key,
    required this.merchantId,
    required this.outletName,
    required this.token,
    required this.customerId,
    required this.salonOwnerId,
  });

  @override
  State<MerchantServiceListScreen> createState() =>
      _MerchantServiceListScreenState();
}

class _MerchantServiceListScreenState extends State<MerchantServiceListScreen> {
  late Future<List<Service>> _futureServices;
  late Future<List<Review>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _futureServices = fetchServicesByMerchant(widget.merchantId, widget.token);
    _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
  }

  void refreshReviews() {
    setState(() {
      _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    });
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
              Tab(text: 'Gift Cards'),
              Tab(text: 'Details'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Services Tab
            FutureBuilder<List<Service>>(
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
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length >= 3 ? 3 : services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return ServiceCard(
                            service: service,
                            customerId: widget.customerId,
                            salonOwnerId: widget.salonOwnerId,
                            token: widget.token,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: const Text(
                          'Other Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            services.length > 3 ? services.length - 3 : 0,
                        itemBuilder: (context, index) {
                          final service = services[index + 3];
                          return ServiceCard(
                            service: service,
                            customerId: widget.customerId,
                            salonOwnerId: widget.salonOwnerId,
                            token: widget.token,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Reviews Tab
            ReviewsTab(
              merchantId: widget.merchantId,
              token: widget.token,
              onReviewSubmitted: refreshReviews,
              futureReviews: _futureReviews,
            ),

            // Portfolio Tab
            const Center(child: Text('Portfolio (Coming Soon)')),

            // Gift Cards Tab
            const Center(child: Text('Gift Cards (Coming Soon)')),

            // Details Tab
            const Center(child: Text('Details (Coming Soon)')),
          ],
        ),
      ),
    );
  }
}

// =========== ServiceCard Widget ===========

class ServiceCard extends StatelessWidget {
  final Service service;
  final String customerId;
  final String salonOwnerId;
  final String token;

  const ServiceCard({
    super.key,
    required this.service,
    required this.customerId,
    required this.salonOwnerId,
    required this.token,
  });

  Future<void> _showBookingDialog(BuildContext context) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String? orderId;

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
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
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
                  onPressed:
                      selectedDate == null || selectedTime == null
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
                            orderId = 'ORD${service.id}${shortId}'.substring(
                              0,
                              21,
                            );

                            try {
                              final paymentResponse = await _initiateOnePayPayment(
                                amount: service.price.toDouble(),
                                orderId: orderId!,
                                customerId: customerId,
                                returnUrl:
                                    'http://api.touchmeapp.com/api/payments/payment-callback',
                                token: token,
                              );

                              if (paymentResponse['status'] == 'success') {
                                final paymentUrl =
                                    paymentResponse['paymentUrl'];
                                final ipgTransactionId =
                                    paymentResponse['ipg_transaction_id'];

                                final bookingResponse = await bookService(
                                  customerId: customerId,
                                  salonOwnerId: salonOwnerId,
                                  saloonServiceId: service.id,
                                  date: formattedDate,
                                  time: formattedTime,
                                  token: token,
                                  ipgTransactionId: ipgTransactionId,
                                );

                                if (bookingResponse['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Booking successfully saved! Proceed to payment.',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Booking failed: ${bookingResponse['message'] ?? ''}',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }

                                if (await canLaunch(paymentUrl)) {
                                  await launch(paymentUrl);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Booking created! Please complete your payment in the new tab. 🎉',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not launch payment URL',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Payment initiation failed: ${paymentResponse['message']}',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error initiating payment: $e'),
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text('Pay & Book'),
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['paymentUrl'] != null && data['ipg_transaction_id'] != null) {
          return {
            'status': 'success',
            'paymentUrl': data['paymentUrl'],
            'ipg_transaction_id': data['ipg_transaction_id'],
          };
        }
        if (data['data'] != null) {
          return {
            'status': 'success',
            'paymentUrl': data['data']['gateway']['redirect_url'],
            'ipg_transaction_id': data['data']['ipg_transaction_id'],
          };
        }
        return {
          'status': 'success',
          'paymentUrl': '',
          'ipg_transaction_id': '',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'status': 'failure',
          'message': error['message'] ?? 'Payment failed',
        };
      }
    } catch (e) {
      return {'status': 'failure', 'message': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.serviceName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Save Up to 10%',
                        style: TextStyle(color: Colors.purple, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.serviceDescription,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs ${service.price}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.price ~/ 60}m',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showBookingDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Pay & Book',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========== ReviewsTab Widget ===========

class ReviewsTab extends StatefulWidget {
  final String merchantId;
  final String token;
  final VoidCallback onReviewSubmitted;
  final Future<List<Review>> futureReviews;

  const ReviewsTab({
    super.key,
    required this.merchantId,
    required this.token,
    required this.onReviewSubmitted,
    required this.futureReviews,
  });

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  // Dialog form values
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  String _improvements = '';
  int _rating = 5;
  bool _submitting = false;

  void _openAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Your Review'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Message'),
                        maxLines: 2,
                        minLines: 1,
                        validator:
                            (val) =>
                                val == null || val.length < 10
                                    ? 'Minimum 10 chars'
                                    : null,
                        onSaved: (val) => _message = val ?? '',
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Improvements',
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                        onSaved: (val) => _improvements = val ?? '',
                      ),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Rating'),
                        value: _rating,
                        onChanged:
                            (val) => setStateDialog(() => _rating = val ?? 5),
                        items: List.generate(
                          5,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1} Star${i == 0 ? '' : 's'}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      _submitting
                          ? null
                          : () async {
                            if (!_formKey.currentState!.validate()) return;
                            _formKey.currentState!.save();
                            setStateDialog(() => _submitting = true);
                            final success = await addReview(
                              merchantId: widget.merchantId,
                              token: widget.token,
                              message: _message,
                              improvements: _improvements,
                              rating: _rating,
                            );
                            setStateDialog(() => _submitting = false);
                            if (success) {
                              if (mounted) Navigator.of(context).pop();
                              widget.onReviewSubmitted();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review submitted!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to submit review.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  child:
                      _submitting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row: "Add" Icon button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.purple,
                size: 28,
              ),
              tooltip: "Add a review",
              onPressed: _openAddReviewDialog,
            ),
            const SizedBox(width: 8),
          ],
        ),
        // Review List
        Expanded(
          child: FutureBuilder<List<Review>>(
            future: widget.futureReviews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading reviews.'));
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Center(child: Text('No reviews yet.'));
              }
              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, i) {
                  final r = reviews[i];
                  return ListTile(
                    leading: Icon(Icons.star, color: Colors.amber[700]),
                    title: Text(r.message),
                    subtitle: Text(
                      'Improvements: ${r.improvements}\nRating: ${r.rating}/5',
                    ),
                    trailing: Text(
                      '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
