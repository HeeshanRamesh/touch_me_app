import 'package:flutter/material.dart';
import 'package:touch_me/merchant_service_list_screen.dart';
import '../models/merchant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MerchantCard extends StatefulWidget {
  final Merchant merchant;
  final String token;
  final String customerId;

  const MerchantCard({
    super.key,
    required this.merchant,
    required this.token,
    required this.customerId,
  });

  @override
  _MerchantCardState createState() => _MerchantCardState();
}

class _MerchantCardState extends State<MerchantCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  // Load favorite status from SharedPreferences
  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_salons') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.merchant.id);
    });
  }

  // Toggle favorite status and save to SharedPreferences
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_salons') ?? [];
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        favorites.add(widget.merchant.id);
      } else {
        favorites.remove(widget.merchant.id);
      }
      prefs.setStringList('favorite_salons', favorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.merchant.id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This merchant has no ID - cannot show services'),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MerchantServiceListScreen(
              merchantId: widget.merchant.id,
              outletName: widget.merchant.outletName,
              token: widget.token,
              customerId: widget.customerId,
              profileImageUrl: widget.merchant.logoUrl,
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    widget.merchant.logoUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_logo.jpg',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.merchant.outletName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.purple : Colors.grey,
                          size: 24,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12/214, ${widget.merchant.outletPhone}',
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