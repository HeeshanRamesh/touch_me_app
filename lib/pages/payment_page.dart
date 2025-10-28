import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;

class PaymentDetailsPage extends StatefulWidget {
  final double? serviceAmount;
  final String? serviceName;
  final String merchantId;
  final String customerId;
  final String token;

  const PaymentDetailsPage({
    super.key,
    this.serviceAmount,
    this.serviceName,
    required this.merchantId,
    required this.customerId,
    required this.token,
  });

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String selectedPayment = 'Visa';

  // Order item prices
  double get order1Price => widget.serviceAmount ?? 0;
  final double order2Price = 0;
  final double taxRate = 0.05; // 10% tax

  // Calculate subtotal
  double get subtotal => order1Price + order2Price;

  // Calculate tax
  double get tax => subtotal * taxRate;

  // Calculate total
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFF8B5CF6),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Section
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Order Items
                      _buildOrderItem(
                        widget.serviceName ?? 'Order:1',
                        'Rs. ${order1Price.toStringAsFixed(2)}',
                      ),
                      if (order2Price > 0)
                        _buildOrderItem(
                          'Order:2',
                          'Rs. ${order2Price.toStringAsFixed(2)}',
                        ),

                      // Subtotal Section
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!, width: 2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSubtotalItem(
                              'Subtotal',
                              'Rs. ${subtotal.toStringAsFixed(2)}',
                            ),
                            _buildSubtotalItem(
                              'App cost (${(taxRate * 100).toInt()}%)',
                              'Rs. ${tax.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),

                      // Payment Methods Section
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Payment Options
                      _buildPaymentOption(
                        'Visa',
                        'VISA',
                        'Visa',
                        Color(0xFF1A1F71),
                        Colors.white,
                      ),
                      _buildPaymentOption(
                        'paypal',
                        'PP',
                        'PayPal',
                        Color(0xFF003087),
                        Colors.white,
                      ),
                      _buildPaymentOption(
                        'Cash',
                        'CASH',
                        'Cash',
                        Color(0xFF22C55E),
                        Colors.white,
                      ),

                      // Total Section
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Rs. ${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add some bottom padding
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Checkout Button - Fixed at bottom
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _proceedToCheckout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, String price) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 16, color: Colors.black87)),
          Text(
            price,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String iconText,
    String label,
    Color iconColor,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  iconText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selectedPayment == value
                          ? Color(0xFF8B5CF6)
                          : Colors.grey[400]!,
                  width: 2,
                ),
                color:
                    selectedPayment == value
                        ? Color(0xFF8B5CF6)
                        : Colors.transparent, // Fill when selected
              ),
              child:
                  selectedPayment == value
                      ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white, // Inner dot for contrast
                          ),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _proceedToCheckout() async {
    // Generate a unique order ID
    final shortId = DateTime.now().millisecondsSinceEpoch.toString().substring(
      5,
    );
    final baseOrderId = 'ORD${widget.serviceName ?? 'SERVICE'}$shortId';
    final orderId =
        baseOrderId.length <= 21 ? baseOrderId : baseOrderId.substring(0, 21);

    try {
      // Initiate payment
      final paymentResponse = await _initiateOnePayPayment(
        amount: total,
        orderId: orderId,
        customerId: widget.customerId,
        returnUrl: 'http://api.touchmeapp.com/api/payments/payment-callback',
        token: widget.token,
      );

      if (paymentResponse['status'] == 'success' &&
          paymentResponse['paymentUrl'] != null) {
        final paymentUrl = paymentResponse['paymentUrl'];
        await launchPaymentURL(paymentUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Proceeding to payment. Please complete the payment.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> launchPaymentURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!uri.isAbsolute || !['http', 'https'].contains(uri.scheme)) {
        throw 'Invalid URL: $url';
      }

      if (await canLaunchUrl(uri)) {
        bool success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!success) {
          success = await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
        if (success) return;
      }
      // Fallback to WebView
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WebViewPage(url: url)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching payment URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      return {'status': 'failure', 'message': e.toString()};
    }
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
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() => isLoading = true);
              },
              onPageFinished: (url) {
                setState(() => isLoading = false);
              },
              onWebResourceError: (WebResourceError error) {
                setState(() {
                  isLoading = false;
                  errorMessage = error.description;
                });
              },
            ),
          );
    controller.loadRequest(Uri.parse(widget.url)).catchError((e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    });
    if (Platform.isAndroid) {
      controller.setBackgroundColor(Colors.white);
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
