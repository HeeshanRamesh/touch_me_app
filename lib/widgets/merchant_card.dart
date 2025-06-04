import 'package:flutter/material.dart';
import 'package:touch_me/merchant_service_list_screen.dart';
import '../models/merchant.dart';

class MerchantCard extends StatelessWidget {
  final Merchant merchant;
  final String token;

  const MerchantCard({super.key, required this.merchant, required this.token, required String customerId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
     onTap: () {
  print('🆔 Navigating to services for merchant ID: ${merchant.id}');
  if (merchant.id.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This merchant has no ID - cannot show services'),
      ),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MerchantServiceListScreen(
        merchantId: merchant.id,
        outletName: merchant.outletName,
        token: token,
        customerId:'682acdf6ad3ad62944028a99', // Replace with actual customerId
                  salonOwnerId: '682acd07ad3ad62944028a93',
      ),
    ),
  );
},
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                merchant.logoUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default_logo.jpg', // ✅ Ensure this asset exists
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.outletName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12/214, ${merchant.outletPhone}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '5.0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Text('| 226 Reviews', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
