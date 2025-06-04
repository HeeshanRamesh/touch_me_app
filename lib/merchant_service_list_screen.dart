import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/service.dart';
import '../services/services.dart';
import '../services/bookings.dart';
import 'merchant_service_list_screen.dart'; // Adjust import if needed


class MerchantServiceListScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(outletName),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
        body: FutureBuilder<List<Service>>(
          future: fetchServicesByMerchant(merchantId, token),
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
                              outletName,
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
                        const SizedBox(height: 12),
                        const TabBar(
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.black,
                          labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          isScrollable: true,
                          tabs: [
                            Tab(text: 'Services'),
                            Tab(text: 'Reviews'),
                            Tab(text: 'Portfolio'),
                            Tab(text: 'Gift Cards'),
                            Tab(text: 'Details'),
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
                        customerId: customerId,
                        salonOwnerId: salonOwnerId,
                        token: token,
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
                    itemCount: services.length > 3 ? services.length - 3 : 0,
                    itemBuilder: (context, index) {
                      final service = services[index + 3];
                      return ServiceCard(
                        service: service,
                        customerId: customerId,
                        salonOwnerId: salonOwnerId,
                        token: token,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

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
                            if (selectedDate == null || selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select both date and time',
                                  ),
                                ),
                              );
                              return;
                            }

                            final formattedDate =
                                '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                            final formattedTime =
                                '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                            final shortId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString()
                                .substring(5); // make it shorter
                            orderId = 'ORD${service.id}${shortId}'.substring(
                              0,
                              21,
                            ); // limit to 21 characters


                            try {
                              // 1. Initiate OnePay payment (amount is in LKR, not divided by 100!)
                              final paymentResponse = await _initiateOnePayPayment(
                                amount:
                                    service.price
                                        .toDouble(), // Pass the price as LKR, e.g., 1500.00
                                orderId: orderId!,
                                customerId: customerId,
                                returnUrl:
                                    'http://192.168.177.109:6000/api/payments/payment-callback',
                                token: token,
                              );

                              if (paymentResponse['status'] == 'success') {
                                final paymentUrl =
                                    paymentResponse['paymentUrl'];
                                final ipgTransactionId =
                                    paymentResponse['ipg_transaction_id'];

                                // 2. Book the service and save the transaction ID
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


                                // 3. Open the payment gateway URL
                                if (await canLaunch(paymentUrl)) {
                                  await launch(paymentUrl);
                                  Navigator.pop(context);

                                  // Show booking + payment initiation success
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
        Uri.parse('http://192.168.177.109:6000/api/payments/onepay-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Remove if not required
        },
        body: jsonEncode({
          'amount': amount.toStringAsFixed(2), // "1500.00"
          'reference': orderId,
          'transactionRedirectUrl': returnUrl,
          'customerFirstName': 'Test',
          'customerLastName': 'User',
          'customerEmail': 'testuser@gmail.com',
          'customerPhoneNumber': '+94770000000',
        }),
      );

      print('✅ OnePay Response Status: ${response.statusCode}');
      print('📦 OnePay Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Flexible extraction for backend shape
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

        // fallback if shape unexpected
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
      print('❌ Error initiating OnePay payment: $e');
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
