import 'package:flutter/material.dart';

class PaymentDetailsPage extends StatefulWidget {
  final double? serviceAmount;
  final String? serviceName;
  
  const PaymentDetailsPage({
    super.key,
    this.serviceAmount,
    this.serviceName,
  });
  
  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String selectedPayment = 'Visa';
  
  // Order item prices
  double get order1Price => widget.serviceAmount ?? 0;
  final double order2Price = 0;
  final double taxRate = 0.10; // 10% tax
  
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
                        'Rs. ${order1Price.toStringAsFixed(2)}'
                      ),
                      if (order2Price > 0)
                        _buildOrderItem('Order:2', 'Rs. ${order2Price.toStringAsFixed(2)}'),

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
                            _buildSubtotalItem('Subtotal', 'Rs. ${subtotal.toStringAsFixed(2)}'),
                            _buildSubtotalItem('Tax (${(taxRate * 100).toInt()}%)', 'Rs. ${tax.toStringAsFixed(2)}'),
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

                      // Add some bottom padding to ensure content doesn't get hidden behind button
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildOrderItem(String name, String price) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedPayment == value
                      ? Color(0xFF8B5CF6)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: selectedPayment == value
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          shape: BoxShape.circle,
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

  void _proceedToCheckout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout'),
          content: Text(
            'Proceeding to checkout with ${selectedPayment.toUpperCase()} payment method.\n\nTotal Amount: Rs. ${total.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}