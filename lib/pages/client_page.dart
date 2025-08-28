import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart';

class CompletedBookingsPage extends StatefulWidget {
  const CompletedBookingsPage({super.key});

  @override
  State<CompletedBookingsPage> createState() => _CompletedBookingsPageState();
}

class _CompletedBookingsPageState extends State<CompletedBookingsPage> {
  Future<List<Booking>>? _futureCompletedBookings;
  final _storage = const FlutterSecureStorage();
  bool _showTable = false; // Toggle between list and table view

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  @override
  void initState() {
    super.initState();
    _loadCompletedBookings();
  }

  void _loadCompletedBookings() async {
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
    setState(() {
      _futureCompletedBookings = fetchCompletedBookings(token);
    });
  }

  Future<List<Booking>> fetchCompletedBookings(String token) async {
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
      final completedBookings =
          bookings
              .map((b) => Booking.fromJson(b))
              .where((booking) => booking.status == 'Completed')
              .toList();
      return completedBookings;
    } else {
      throw Exception('Failed to fetch completed bookings: ${response.body}');
    }
  }

  Map<String, Map<String, dynamic>> _getCustomerUsageCount(
    List<Booking> bookings,
  ) {
    Map<String, Map<String, dynamic>> customerCount = {};
    for (var booking in bookings) {
      String customerName =
          booking.customerName.isEmpty ? 'N/A' : booking.customerName;

      if (!customerCount.containsKey(customerName)) {
        customerCount[customerName] = {'count': 0, 'totalAmount': 0.0};
      }

      customerCount[customerName]!['count']++;

      // Parse price and add to total
      double price = 0.0;
      try {
        if (booking.price != 'N/A' && booking.price.isNotEmpty) {
          price = double.parse(booking.price.replaceAll(RegExp(r'[^\d.]'), ''));
        }
      } catch (e) {
        price = 0.0;
      }
      customerCount[customerName]!['totalAmount'] += price;
    }
    return customerCount;
  }

  Widget _buildCustomerUsageTable(List<Booking> bookings) {
    final customerUsage = _getCustomerUsageCount(bookings);
    final sortedCustomers =
        customerUsage.entries.toList()..sort(
          (a, b) => b.value['count'].compareTo(a.value['count']),
        ); // Sort by usage count descending

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => const Color(0xFF6A1B9A).withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Customer\nName',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Service\nCount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Total\nAmount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows:
              sortedCustomers.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(entry.key, style: const TextStyle(fontSize: 14)),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${entry.value['count']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\Rs.${entry.value['totalAmount'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        // title: const Text('Completed Bookings',
        //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        // ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_showTable ? Icons.list : Icons.table_chart),
            onPressed: () {
              setState(() {
                _showTable = !_showTable;
              });
            },
          ),
        ],
      ),
      body:
          _futureCompletedBookings == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Booking>>(
                future: _futureCompletedBookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return const Center(child: Text('No client found.'));
                  }

                  // Show table view or list view based on toggle
                  if (_showTable) {
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B9A).withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Customer Service Usage Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6A1B9A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(child: _buildCustomerUsageTable(bookings)),
                      ],
                    );
                  }

                  // Original list view with price added
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.customerName.isEmpty
                                          ? 'N/A'
                                          : booking.customerName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF6A1B9A,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      booking.price == 'N/A'
                                          ? 'N/A'
                                          : '\Rs.${booking.price}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6A1B9A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.serviceName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${booking.date} | ${booking.time}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
