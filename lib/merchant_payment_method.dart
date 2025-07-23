import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
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

  Future<void> saveToMongoDB(List<String> selectedMethods) async {
    final url = Uri.parse('http://localhost:3000/api/payment-methods'); // Replace with your backend URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': 'default_user', // Replace with actual user ID if available
          'selectedMethods': selectedMethods,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment methods saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw Exception('Failed to save payment methods: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving payment methods: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void confirmSelection() {
    final selectedMethods = paymentMethods
        .where((method) => method.isSelected)
        .map((method) => method.name)
        .toList();

    if (selectedMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one payment method.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Selected Payment Methods'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedMethods
                .map((method) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(method),
                        ],
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                await saveToMongoDB(selectedMethods); // Save to MongoDB
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('SAVE'),
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
        title: Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: paymentMethods.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 16),
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
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedCount > 0
                                  ? Color(0xFF667eea)
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
                                color: selectedCount > 0
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: clearSelection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Color(0xFF667eea),
                                    elevation: 0,
                                    side: BorderSide(
                                      color: Color(0xFF667eea),
                                      width: 2,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'CLEAR ALL',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: confirmSelection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF667eea),
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor:
                                        Color(0xFF667eea).withOpacity(0.4),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'CONFIRM',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
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
      duration: Duration(milliseconds: 150),
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
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.paymentMethod.isSelected
                ? Color(0xFF667eea)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.paymentMethod.isSelected
                  ? Color(0xFF667eea)
                  : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.paymentMethod.isSelected
                    ? Color(0xFF667eea).withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: widget.paymentMethod.isSelected ? 12 : 6,
                offset: Offset(0, widget.paymentMethod.isSelected ? 6 : 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.paymentMethod.isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.paymentMethod.icon,
                    size: 28,
                    color: widget.paymentMethod.isSelected
                        ? Colors.white
                        : Color(0xFF667eea),
                  ),
                ),
                SizedBox(width: 16),
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
                          color: widget.paymentMethod.isSelected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.paymentMethod.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.paymentMethod.isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.paymentMethod.isSelected
                        ? Colors.white
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.paymentMethod.isSelected
                          ? Colors.white
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: widget.paymentMethod.isSelected
                      ? Icon(
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