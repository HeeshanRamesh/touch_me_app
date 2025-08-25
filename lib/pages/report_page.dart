import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart';
import 'package:intl/intl.dart';

// Model for service details
class ServiceDetail {
  final String id;
  final String serviceName;
  final double price;

  ServiceDetail({
    required this.id,
    required this.serviceName,
    required this.price,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    try {
      return ServiceDetail(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        serviceName:
            json['serviceName']?.toString() ?? json['name']?.toString() ?? '',
        price: _parsePrice(json['price']),
      );
    } catch (e) {
      print('Error parsing service from JSON: $json');
      print('Error: $e');
      rethrow;
    }
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }
}

// Model for daily sales entry
class SalesEntry {
  final String id;
  final String serviceName;
  final double price;
  final DateTime createdAt;
  final String status;
  final String bookingId;

  SalesEntry({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.createdAt,
    required this.status,
    required this.bookingId,
  });

  factory SalesEntry.fromJson(Map<String, dynamic> json) {
    return SalesEntry(
      id: json['id'].toString(),
      serviceName: json['serviceName'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'completed',
      bookingId: json['bookingId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'bookingId': bookingId,
    };
  }
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<SalesEntry> todaySales = [];
  List<ServiceDetail> services = [];
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  double totalRevenue = 0.0;
  double weeklyRevenue = 0.0;
  double monthlyRevenue = 0.0;
  int monthlySalesCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadServices();
    await _loadTodayBookings();
    await _calculateWeeklyRevenue();
    await _calculateMonthlyRevenue();
  }

  // Get authentication token
  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Load all services from API
  Future<void> _loadServices() async {
    try {
      final token = await _getToken();
      if (token == null) {
        _showError('No authentication token found. Please log in.');
        return;
      }

      final url = Uri.parse('http://api.touchmeapp.com/api/services');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Services API Response Status: ${response.statusCode}');
      print('Services API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed services data: $data');

        // Handle different possible response structures
        List<dynamic> servicesList;
        if (data is List) {
          servicesList = data;
        } else if (data is Map && data.containsKey('services')) {
          servicesList = data['services'] as List<dynamic>;
        } else if (data is Map && data.containsKey('data')) {
          final dataField = data['data'];
          if (dataField is List) {
            servicesList = dataField;
          } else if (dataField is Map && dataField.containsKey('services')) {
            servicesList = dataField['services'] as List<dynamic>;
          } else {
            throw Exception(
              'Unexpected data structure in services API response',
            );
          }
        } else {
          throw Exception('Unexpected response structure: ${data.runtimeType}');
        }

        print('Services list length: ${servicesList.length}');
        setState(() {
          services =
              servicesList.map((s) {
                print('Processing service: $s');
                return ServiceDetail.fromJson(s);
              }).toList();
        });
        print('Loaded ${services.length} services');
      } else {
        throw Exception(
          'Failed to load services: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('Error loading services: $e');
      print('Stack trace: $stackTrace');
      _showError('Failed to load services: $e');
    }
  }

  // Load today's completed bookings from API
  Future<void> _loadTodayBookings() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      if (token == null) {
        _showError('No authentication token found. Please log in.');
        return;
      }

      // Fetch all bookings
      final url = Uri.parse(
        'http://api.touchmeapp.com/api/bookings/my/bookings',
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Bookings API Response Status: ${response.statusCode}');
      print('Bookings API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bookings = data['bookings'] as List<dynamic>;

        // Filter today's completed bookings
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        print('Looking for bookings on date: $today');

        // Process raw booking data to get service IDs
        List<SalesEntry> salesEntries = [];
        double totalAmount = 0.0;

        for (final bookingData in bookings) {
          print('Processing booking: $bookingData');

          // Check if booking is completed and today
          final status = bookingData['status']?.toString().toLowerCase() ?? '';
          final bookingDate = bookingData['date']?.toString() ?? '';

          print('Booking status: $status, date: $bookingDate');

          if (status == 'completed' && bookingDate == today) {
            // Extract service ID from booking data
            String serviceId = '';
            if (bookingData['saloonServiceId'] is String) {
              serviceId = bookingData['saloonServiceId'];
            } else if (bookingData['saloonServiceId'] is Map) {
              serviceId =
                  bookingData['saloonServiceId']['_id'] ??
                  bookingData['saloonServiceId']['id'] ??
                  '';
            }

            print('Found completed booking with service ID: $serviceId');

            // Find service price from services list
            final service = services.firstWhere(
              (s) => s.id == serviceId,
              orElse: () {
                print('Service not found for ID: $serviceId');
                print(
                  'Available services: ${services.map((s) => '${s.id}: ${s.serviceName}').join(', ')}',
                );
                return ServiceDetail(
                  id: serviceId,
                  serviceName:
                      bookingData['saloonServiceId']?['serviceName'] ??
                      'Unknown Service',
                  price: 0.0,
                );
              },
            );

            print(
              'Found service: ${service.serviceName} with price: ${service.price}',
            );

            final booking = Booking.fromJson(bookingData);
            final salesEntry = SalesEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString() + booking.id,
              serviceName: service.serviceName,
              price: service.price,
              createdAt: _parseBookingDateTime(booking.date, booking.time),
              status: 'completed',
              bookingId: booking.id,
            );

            salesEntries.add(salesEntry);
            totalAmount += service.price;

            print(
              'Added sales entry: ${salesEntry.serviceName} - Rs ${salesEntry.price}',
            );
          }
        }

        print('Total sales entries: ${salesEntries.length}');
        print('Total amount: Rs $totalAmount');

        setState(() {
          todaySales = salesEntries;
          totalRevenue = totalAmount;
        });

        // Save to local storage
        await _saveSalesData();
      } else {
        throw Exception(
          'Failed to fetch bookings: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('Error loading today\'s bookings: $e');
      print('Stack trace: $stackTrace');
      _showError('Failed to load today\'s sales data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Calculate weekly revenue (last 7 days)
  Future<void> _calculateWeeklyRevenue() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final url = Uri.parse(
        'http://api.touchmeapp.com/api/bookings/my/bookings',
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

        final now = DateTime.now();
        final weekStart = now.subtract(
          Duration(days: 6),
        ); // Last 7 days including today

        double weeklyTotal = 0.0;

        for (final bookingData in bookings) {
          final status = bookingData['status']?.toString().toLowerCase() ?? '';
          final bookingDateStr = bookingData['date']?.toString() ?? '';

          if (status == 'completed' && bookingDateStr.isNotEmpty) {
            final bookingDate = DateTime.parse(bookingDateStr);

            if (bookingDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
                bookingDate.isBefore(now.add(Duration(days: 1)))) {
              String serviceId = '';
              if (bookingData['saloonServiceId'] is String) {
                serviceId = bookingData['saloonServiceId'];
              } else if (bookingData['saloonServiceId'] is Map) {
                serviceId =
                    bookingData['saloonServiceId']['_id'] ??
                    bookingData['saloonServiceId']['id'] ??
                    '';
              }

              final service = services.firstWhere(
                (s) => s.id == serviceId,
                orElse:
                    () => ServiceDetail(
                      id: serviceId,
                      serviceName: 'Unknown',
                      price: 0.0,
                    ),
              );

              weeklyTotal += service.price;
            }
          }
        }

        setState(() {
          weeklyRevenue = weeklyTotal;
        });
      }
    } catch (e) {
      print('Error calculating weekly revenue: $e');
    }
  }

  // Calculate monthly revenue and sales count
  Future<void> _calculateMonthlyRevenue() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final url = Uri.parse(
        'http://api.touchmeapp.com/api/bookings/my/bookings',
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

        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);

        double monthlyTotal = 0.0;
        int salesCount = 0;

        for (final bookingData in bookings) {
          final status = bookingData['status']?.toString().toLowerCase() ?? '';
          final bookingDateStr = bookingData['date']?.toString() ?? '';

          if (status == 'completed' && bookingDateStr.isNotEmpty) {
            final bookingDate = DateTime.parse(bookingDateStr);

            if (bookingDate.isAfter(monthStart.subtract(Duration(days: 1))) &&
                bookingDate.isBefore(monthEnd.add(Duration(days: 1)))) {
              String serviceId = '';
              if (bookingData['saloonServiceId'] is String) {
                serviceId = bookingData['saloonServiceId'];
              } else if (bookingData['saloonServiceId'] is Map) {
                serviceId =
                    bookingData['saloonServiceId']['_id'] ??
                    bookingData['saloonServiceId']['id'] ??
                    '';
              }

              final service = services.firstWhere(
                (s) => s.id == serviceId,
                orElse:
                    () => ServiceDetail(
                      id: serviceId,
                      serviceName: 'Unknown',
                      price: 0.0,
                    ),
              );

              monthlyTotal += service.price;
              salesCount++;
            }
          }
        }

        setState(() {
          monthlyRevenue = monthlyTotal;
          monthlySalesCount = salesCount;
        });
      }
    } catch (e) {
      print('Error calculating monthly revenue: $e');
    }
  }

  // Extract service ID from booking
  String _extractServiceId(Booking booking) {
    // The booking model should have the saloonServiceId
    // We need to extract it from the booking data
    // Since the booking.dart model doesn't expose it directly,
    // we'll need to get it from the raw JSON during booking processing
    return ''; // Will be handled in the booking processing loop
  }

  // Parse booking date and time
  DateTime _parseBookingDateTime(String date, String time) {
    try {
      final dateTime = DateTime.parse('$date $time:00');
      return dateTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  // Save sales data to local storage
  Future<void> _saveSalesData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final salesJson = todaySales.map((sale) => sale.toJson()).toList();
      await _storage.write(
        key: 'daily_sales_$today',
        value: jsonEncode(salesJson),
      );
      await _storage.write(
        key: 'daily_revenue_$today',
        value: totalRevenue.toString(),
      );
    } catch (e) {
      print('Error saving sales data: $e');
    }
  }

  // Load saved sales data from local storage
  Future<void> _loadSavedSalesData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final salesData = await _storage.read(key: 'daily_sales_$today');
      final revenueData = await _storage.read(key: 'daily_revenue_$today');

      if (salesData != null) {
        final List<dynamic> salesList = jsonDecode(salesData);
        setState(() {
          todaySales =
              salesList.map((item) => SalesEntry.fromJson(item)).toList();
          totalRevenue = revenueData != null ? double.parse(revenueData) : 0.0;
        });
      }
    } catch (e) {
      print('Error loading saved sales data: $e');
    }
  }

  // Show error message
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // Show finish day dialog
  void _showFinishDayDialog() {
    if (todaySales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No completed sales to finish today'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daily Sales Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Completed Services: ${todaySales.length}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Revenue: Rs ${totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Services completed:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: todaySales.length,
                  itemBuilder: (context, index) {
                    final sale = todaySales[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sale.serviceName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            'Rs ${sale.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Daily sales recorded: Rs ${totalRevenue.toStringAsFixed(2)}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Finish Day',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Refresh data
  Future<void> _refreshData() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // IconButton(
          //   onPressed: _refreshData,
          //   icon: const Icon(Icons.refresh, color: Colors.white),
          //   tooltip: 'Refresh Data',
          // ),
          if (todaySales.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: _showFinishDayDialog,
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Finish Day'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Overview Cards
                Row(
                  children: [
                    // Today's Revenue Card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.today,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Today\'s Revenue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Rs ${totalRevenue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${todaySales.length} services',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Weekly and Monthly Revenue Cards
                Row(
                  children: [
                    // Weekly Revenue Card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.date_range,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'This Week',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Rs ${weeklyRevenue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last 7 days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Monthly Revenue Card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'This Month',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Rs ${monthlyRevenue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$monthlySalesCount total sales',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Revenue Summary Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Today\'s Revenue',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          if (_isLoading)
                            const CircularProgressIndicator()
                          else if (todaySales.isEmpty)
                            Column(
                              children: const [
                                Icon(
                                  Icons.monetization_on_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'No sales today',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Revenue will appear when services are completed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        'Rs ${totalRevenue.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${todaySales.length} services completed',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Services List
                if (todaySales.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Completed Services',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: todaySales.length,
                            separatorBuilder:
                                (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final sale = todaySales[index];

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                title: Text(
                                  sale.serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat('HH:mm').format(sale.createdAt),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    'Rs ${sale.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Quick Stats Card
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickStatItem(
                              'Avg per Service',
                              todaySales.isNotEmpty
                                  ? 'Rs ${(totalRevenue / todaySales.length).toStringAsFixed(2)}'
                                  : 'Rs 0.00',
                              Icons.attach_money,
                              Colors.blue,
                            ),
                            _buildQuickStatItem(
                              'Weekly Avg',
                              'Rs ${(weeklyRevenue / 7).toStringAsFixed(2)}',
                              Icons.trending_up,
                              Colors.orange,
                            ),
                            _buildQuickStatItem(
                              'Monthly Target',
                              monthlyRevenue > 10000 ? 'On Track' : 'Behind',
                              monthlyRevenue > 10000
                                  ? Icons.check_circle
                                  : Icons.warning,
                              monthlyRevenue > 10000
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
