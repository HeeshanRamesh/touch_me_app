import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:touch_me/models/booking.dart';
import 'package:intl/intl.dart';

// Model for daily sales entry
class SalesEntry {
  final String id;
  final String serviceName;
  final double price;
  final DateTime createdAt;
  final String status; // 'pending' or 'completed'

  SalesEntry({
    required this.id,
    required this.serviceName,
    required this.price,
    required this.createdAt,
    this.status = 'pending',
  });

  factory SalesEntry.fromJson(Map<String, dynamic> json) {
    return SalesEntry(
      id: json['id'].toString(),
      serviceName: json['serviceName'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  SalesEntry copyWith({String? status}) {
    return SalesEntry(
      id: id,
      serviceName: serviceName,
      price: price,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentIndex = 0;
  List<SalesEntry> todaySales = [];
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodaySales();
  }

  // Load today's sales from storage
  Future<void> _loadTodaySales() async {
    setState(() => _isLoading = true);
    
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final salesData = await _storage.read(key: 'daily_sales_$today');
      
      if (salesData != null) {
        final List<dynamic> salesList = jsonDecode(salesData);
        setState(() {
          todaySales = salesList.map((item) => SalesEntry.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print('Error loading sales data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Save sales data to storage
  Future<void> _saveSalesData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final salesJson = todaySales.map((sale) => sale.toJson()).toList();
      await _storage.write(key: 'daily_sales_$today', value: jsonEncode(salesJson));
    } catch (e) {
      print('Error saving sales data: $e');
    }
  }

  // Mark a sale as completed
  Future<void> _completeSale(String saleId) async {
    setState(() {
      final index = todaySales.indexWhere((sale) => sale.id == saleId);
      if (index != -1) {
        todaySales[index] = todaySales[index].copyWith(status: 'completed');
      }
    });
    await _saveSalesData();
  }

  // Calculate total completed sales
  double get totalCompletedSales {
    return todaySales
        .where((sale) => sale.status == 'completed')
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Calculate total pending sales
  double get totalPendingSales {
    return todaySales
        .where((sale) => sale.status == 'pending')
        .fold(0.0, (sum, sale) => sum + sale.price);
  }

  // Show finish day dialog
  void _showFinishDayDialog() {
    final completedSales = todaySales.where((sale) => sale.status == 'completed').toList();
    
    if (completedSales.isEmpty) {
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
                'Completed Services: ${completedSales.length}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Revenue: Rs ${totalCompletedSales.toStringAsFixed(2)}',
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
                  itemCount: completedSales.length,
                  itemBuilder: (context, index) {
                    final sale = completedSales[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      'Daily sales recorded: Rs ${totalCompletedSales.toStringAsFixed(2)}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Text(
                      "Report Page",
                      style: TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (todaySales.any((sale) => sale.status == 'completed'))
                    ElevatedButton.icon(
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
                ],
              ),
              const SizedBox(height: 20),

              // Daily Sales Report Card
              SizedBox(
                width: double.infinity,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daily Sales Report',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (todaySales.isEmpty)
                          Column(
                            children: const [
                              Icon(Icons.receipt_long, size: 40, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                'No sales today',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Sales will appear here when bookings are made',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              // Summary row
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pending',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Rs ${totalPendingSales.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Completed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Rs ${totalCompletedSales.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Sales list
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: todaySales.length,
                                itemBuilder: (context, index) {
                                  final sale = todaySales[index];
                                  final isCompleted = sale.status == 'completed';
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isCompleted ? Colors.green.shade200 : Colors.orange.shade200,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sale.serviceName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Rs ${sale.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isCompleted ? Colors.green : Colors.orange,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('HH:mm').format(sale.createdAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isCompleted)
                                          ElevatedButton(
                                            onPressed: () => _completeSale(sale.id),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(80, 36),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                            ),
                                            child: const Text(
                                              'Complete',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Completed',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Your Sales Card (keeping the original design)
              SizedBox(
                height: 300,
                width: 500,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Your Sales',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bar_chart, size: 40),
                            const SizedBox(height: 10),
                            if (totalCompletedSales > 0) ...[
                              Text(
                                'Today\'s Revenue',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rs ${totalCompletedSales.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Your sale is empty',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Make some appointments to get started the sales',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}