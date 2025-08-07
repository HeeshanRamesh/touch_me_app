import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  bool isSelected;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isSelected = false,
  });
}

class PaymentMethodsPage extends StatefulWidget {
  final String? merchantId;

  const PaymentMethodsPage({Key? key, this.merchantId}) : super(key: key);

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final storage = const FlutterSecureStorage();

  String? _merchantId;
  String? _authToken;
  bool _isLoading = false;

  List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'cash',
      name: 'Cash',
      description: 'Traditional cash payments',
      icon: Icons.attach_money,
    ),
    PaymentMethod(
      id: 'debit-card',
      name: 'Debit Card',
      description: 'Direct bank account payments',
      icon: Icons.credit_card,
    ),
    PaymentMethod(
      id: 'credit-card',
      name: 'Credit Card',
      description: 'Visa, Mastercard, Amex',
      icon: Icons.credit_card_outlined,
    ),
    PaymentMethod(
      id: 'online-payment',
      name: 'Online Payment',
      description: 'Web-based transactions',
      icon: Icons.language,
    ),
    PaymentMethod(
      id: 'mobile-payment',
      name: 'Mobile Payment',
      description: 'Apple Pay, Google Pay',
      icon: Icons.phone_android,
    ),
    PaymentMethod(
      id: 'lanka-pay',
      name: 'Lanka Pay',
      description: 'Local Sri Lankan payment',
      icon: Icons.flag,
    ),
    PaymentMethod(
      id: 'qr-pay',
      name: 'QR Pay',
      description: 'QR code payments',
      icon: Icons.qr_code,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _initializeMerchantData();
  }

  Future<void> _initializeMerchantData() async {
    try {
      _merchantId = widget.merchantId ?? await storage.read(key: 'merchantId');
      _authToken = await storage.read(key: 'authToken');
      if (_merchantId == null || _authToken == null) {
        _showSnackBar('Missing merchant ID or auth token', Colors.orange);
      }
    } catch (error) {
      _showSnackBar('Error initializing merchant data', Colors.red);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int get selectedCount =>
      paymentMethods.where((method) => method.isSelected).length;

  void clearSelection() {
    setState(() {
      for (var method in paymentMethods) {
        method.isSelected = false;
      }
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> saveToAPI(List<String> selectedMethodIds) async {
    if (_merchantId == null || _authToken == null) {
      _showSnackBar('Missing authentication data', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Clean the merchant ID to remove any whitespace
      final cleanMerchantId = _merchantId!.trim();
      final cleanAuthToken = _authToken!.trim();

      final url = Uri.parse(
        'http://api.touchmeapp.com/api/merchants/$cleanMerchantId/payment',
      );

      // Convert method IDs to display names that the API expects
      final methodIdToName = {
        'cash': 'Cash',
        'debit-card': 'Debit Card',
        'credit-card': 'Credit Card',
        'online-payment': 'Online Payment',
        'mobile-payment': 'Mobile Payment',
        'lanka-pay': 'Lanka Pay',
        'qr-pay': 'QR Pay',
      };

      // For now, send requests for each payment method individually
      // since the API expects single paymentOption format
      List<String> successfulMethods = [];
      List<String> failedMethods = [];

      for (String methodId in selectedMethodIds) {
        final paymentName = methodIdToName[methodId] ?? methodId;
        final requestBody = {'paymentOption': paymentName};

        print('Sending request for: $paymentName');
        print('Request body: ${jsonEncode(requestBody)}');

        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $cleanAuthToken',
                'Accept': 'application/json',
              },
              body: jsonEncode(requestBody),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Request timeout');
              },
            );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          successfulMethods.add(paymentName);
        } else {
          failedMethods.add(paymentName);
          print('Failed to save $paymentName: ${response.statusCode}');
        }
      }

      // Show results
      if (failedMethods.isEmpty) {
        _showSnackBar('All payment methods saved successfully!', Colors.green);
      } else if (successfulMethods.isEmpty) {
        _showSnackBar('Failed to save payment methods', Colors.red);
      } else {
        _showSnackBar(
          'Saved: ${successfulMethods.length}, Failed: ${failedMethods.length}',
          Colors.orange,
        );
      }
    } catch (error) {
      String errorMessage = 'Error saving payment methods';
      if (error.toString().contains('SocketException') ||
          error.toString().contains('Failed host lookup')) {
        errorMessage =
            'Network connection error. Please check your internet connection.';
      } else if (error.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else {
        errorMessage = 'Error: ${error.toString()}';
      }
      _showSnackBar(errorMessage, Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void confirmSelection() {
    final selectedMethods =
        paymentMethods.where((method) => method.isSelected).toList();

    if (selectedMethods.isEmpty) {
      _showSnackBar('Please select at least one payment method.', Colors.red);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Selected Payment Methods'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                selectedMethods
                    .map(
                      (method) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(method.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : () async {
                        final selectedMethodIds =
                            selectedMethods.map((method) => method.id).toList();
                        await saveToAPI(selectedMethodIds);
                        if (!_isLoading && mounted) {
                          Navigator.of(context).pop();
                        }
                      },
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('SAVE'),
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
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Saving payment methods...'),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: paymentMethods.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return PaymentMethodCard(
                                paymentMethod: paymentMethods[index],
                                onTap: () {
                                  setState(() {
                                    paymentMethods[index].isSelected =
                                        !paymentMethods[index].isSelected;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                selectedCount > 0
                                    ? const Color(0xFF667eea)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedCount == 0
                                ? 'No payment methods selected'
                                : selectedCount == 1
                                ? '1 payment method selected'
                                : '$selectedCount payment methods selected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedCount > 0
                                      ? Colors.white
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : clearSelection,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: const Color(0xFF667eea),
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'CLEAR ALL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : confirmSelection,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: const Color(
                                    0xFF667eea,
                                  ).withOpacity(0.4),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'CONFIRM',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                              ),
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
}

class PaymentMethodCard extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    required this.onTap,
  }) : super(key: key);

  @override
  _PaymentMethodCardState createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color:
                widget.paymentMethod.isSelected
                    ? const Color(0xFF667eea)
                    : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  widget.paymentMethod.isSelected
                      ? const Color(0xFF667eea)
                      : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    widget.paymentMethod.isSelected
                        ? const Color(0xFF667eea).withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                blurRadius: widget.paymentMethod.isSelected ? 12 : 6,
                offset: Offset(0, widget.paymentMethod.isSelected ? 6 : 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        widget.paymentMethod.isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.paymentMethod.icon,
                    size: 28,
                    color:
                        widget.paymentMethod.isSelected
                            ? Colors.white
                            : const Color(0xFF667eea),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.paymentMethod.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              widget.paymentMethod.isSelected
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.paymentMethod.description,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.paymentMethod.isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        widget.paymentMethod.isSelected
                            ? Colors.white
                            : Colors.transparent,
                    border: Border.all(
                      color:
                          widget.paymentMethod.isSelected
                              ? Colors.white
                              : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      widget.paymentMethod.isSelected
                          ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFF667eea),
                          )
                          : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
