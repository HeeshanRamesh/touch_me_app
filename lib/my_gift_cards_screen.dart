import 'package:flutter/material.dart';
import '../services/gift_cards.dart';
import '../models/purchased_gift_card.dart';

class MyGiftCardsScreen extends StatelessWidget {
  final String token;

  const MyGiftCardsScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gift Cards'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<PurchasedGiftCard>>(
        future: fetchMyGiftCards(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load gift cards'));
          }
          final cards = snapshot.data ?? [];
          if (cards.isEmpty) {
            return const Center(child: Text('No gift cards purchased yet.'));
          }
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final gc = cards[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    gc.giftCardName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code: ${gc.code}',
                        style: const TextStyle(color: Colors.purple),
                      ),
                      Text('Merchant: ${gc.merchantName}'),
                      Text('Value: Rs ${gc.value}'),
                      Text('Status: ${gc.status}'),
                      Text(
                        'Expiry: ${gc.expiryDate.toString().substring(0, 10)}',
                      ),
                    ],
                  ),
                  trailing: Icon(
                    gc.status == 'active' ? Icons.card_giftcard : Icons.lock,
                    color: gc.status == 'active' ? Colors.green : Colors.grey,
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
