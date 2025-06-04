import 'package:flutter/material.dart';
import '../models/merchant.dart';
import '../services/merchant_service.dart';
import '../widgets/merchant_card.dart';

class MerchantListScreen extends StatelessWidget {
  final String serviceName;
  final String token;
  final String customerId; // Add customerId as a parameter

  const MerchantListScreen({
    super.key,
    required this.serviceName,
    required this.token,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
      body: FutureBuilder<List<Merchant>>(
        future: fetchMerchants(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final merchants = snapshot.data ?? [];
          if (merchants.isEmpty) {
            return const Center(
              child: Text(
                'No merchants available for this service.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: merchants.length,
            itemBuilder:
                (context, index) => MerchantCard(
                  merchant: merchants[index],
                  token: token,
                  customerId: customerId, // Pass customerId to MerchantCard
                ),
          );
        },
      ),
    );
  }
}
