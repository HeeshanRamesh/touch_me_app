import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/payment_page.dart';

class BookingConfirmationPage extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String serviceDescription;
  final String date;
  final String time;
  final String serviceId;
  final double totalAmount;
  final String merchantId;
  final String customerId;
  final String token;
  final Map<String, dynamic>? userData; // Add user data parameter

  const BookingConfirmationPage({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.serviceDescription,
    required this.date,
    required this.time,
    required this.serviceId,
    required this.totalAmount,
    required this.merchantId,
    required this.customerId,
    required this.token,
    this.userData, // Optional user data
  });

  @override
  State<BookingConfirmationPage> createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  Map<String, dynamic>? customerData;
  Map<String, dynamic>? serviceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // If user data is already provided, use it
      if (widget.userData != null) {
        setState(() {
          customerData = widget.userData;
        });
      } else {
        // Otherwise, fetch user profile details
        await _fetchCustomerDetails();
      }
      
      await _fetchServiceDetails();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      print('Fetching user profile for ID: ${widget.customerId}');
      final response = await http.get(
        Uri.parse('http://api.touchmeapp.com/api/users/profile/${widget.customerId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      print('User Profile API Response Status: ${response.statusCode}');
      print('User Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          customerData = data;
        });
      } else {
        print('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _fetchServiceDetails() async {
    try {
      print('Fetching service details for ID: ${widget.serviceId}');
      final response = await http.get(
        Uri.parse('http://api.touchmeapp.com/api/services/${widget.serviceId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      print('Service API Response Status: ${response.statusCode}');
      print('Service API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          serviceData = data;
        });
      } else {
        print('Failed to fetch service details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching service details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Booking Confirmation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF6A1B9A),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
          ),
        ),
      );
    }

    // Extract customer data with multiple fallback options
    String customerName = 'Customer';
    String customerPhone = 'N/A';
    String customerEmail = 'N/A';

    if (customerData != null) {
      // Try different possible field names for name
      customerName = customerData!['name'] ?? 
                    customerData!['firstName'] ?? 
                    customerData!['fullName'] ??
                    customerData!['username'] ??
                    customerData!['first_name'] ??
                    customerData!['last_name'] ??
                    '${customerData!['first_name'] ?? ''} ${customerData!['last_name'] ?? ''}'.trim();
      
      if (customerName.isEmpty) customerName = 'Customer';

      // Try different possible field names for phone
      customerPhone = customerData!['phone'] ?? 
                     customerData!['phoneNumber'] ?? 
                     customerData!['phone_number'] ?? 
                     customerData!['mobile'] ?? 
                     customerData!['contactNumber'] ??
                     'N/A';

      // Try different possible field names for email
      customerEmail = customerData!['email'] ?? 
                     customerData!['emailAddress'] ?? 
                     customerData!['email_address'] ?? 
                     'N/A';
    }

    // Debug print
    print('Customer Data: $customerData');
    print('Extracted - Name: $customerName, Phone: $customerPhone, Email: $customerEmail');

    final duration = serviceData?['duration'] != null 
        ? '${serviceData!['duration']} minutes' 
        : '60 minutes'; // Default fallback

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Booking Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Success Icon and Message
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your appointment has been successfully booked',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Debug Information (remove in production)
              // 

              // Booking Details Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Center(
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Booking ID: ${widget.bookingId}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Divider(height: 30),

                      // Service Details
                      const Text(
                        'Service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.serviceDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date & Time Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Date & Time',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.date,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  widget.time,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.schedule,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  duration,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Customer Details
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customerPhone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              customerEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Total Amount
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Rs ${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A1B9A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Payment Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentDetailsPage(
                          serviceAmount: widget.totalAmount,
                          serviceName: widget.serviceName,
                          merchantId: widget.merchantId,
                          customerId: widget.customerId,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}