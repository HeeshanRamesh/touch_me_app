import 'package:flutter/material.dart';
import 'package:touch_me/pages/merchant_service_list_screen.dart';
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

  String _formatOpeningHours() {
    // This would typically come from backend, using placeholder for now
    return "Open 9:00 - 20:00";
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image and favorite button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      widget.merchant.outletPictureUrl.isNotEmpty 
                          ? widget.merchant.outletPictureUrl 
                          : widget.merchant.logoUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No Image Available',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Favorite button overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey[600],
                          size: 24,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                  // Rating badge overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.merchant.rating?.toStringAsFixed(1) ?? '5.0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and description
                    Text(
                      widget.merchant.outletName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Premier salon offering cutting-edge styling and services',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Address
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.merchant.address.isNotEmpty 
                                ? widget.merchant.address 
                                : '123 Beauty Street, Downtown, City 12345',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Opening hours
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatOpeningHours(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Phone number
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.merchant.outletPhone.isNotEmpty 
                              ? widget.merchant.outletPhone 
                              : '+1 (555) 123-4567',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Amenities
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildAmenityChip(Icons.wifi, 'Free WiFi'),
                        _buildAmenityChip(Icons.local_parking, 'Parking Available'),
                        _buildAmenityChip(Icons.free_breakfast, 'Refreshments'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Additional amenities
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Air Conditioning',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Reviews summary
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.merchant.rating?.toStringAsFixed(1) ?? '4.9',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.merchant.reviews ?? 226} Reviews',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}