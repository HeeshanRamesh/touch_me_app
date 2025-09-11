import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class MerchantReviewsPage extends StatefulWidget {
  const MerchantReviewsPage({super.key});

  @override
  _MerchantReviewsPageState createState() => _MerchantReviewsPageState();
}

class _MerchantReviewsPageState extends State<MerchantReviewsPage> {
  final storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? merchantId = await storage.read(key: 'merchantId');
      String? token = await storage.read(key: 'authToken');

      print('Retrieved Merchant ID: $merchantId');
      print('Retrieved Token: $token');

      if (merchantId == null || token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please log in again to view your reviews.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://api.touchmeapp.com/api/reviews/merchant/$merchantId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reviews = data is List ? data : (data['reviews'] ?? []);
          _isLoading = false;
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage =
              errorData['error']?['message'] ??
              'Unable to load reviews. Please try again.';
        });
      }
    } catch (e) {
      print('Error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Connection problem. Please check your internet and try again.';
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date not available';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Date not available';
    }
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;

    int totalRating = 0;
    int validRatings = 0;

    for (var review in _reviews) {
      final rating = int.tryParse(review['rating']?.toString() ?? '0') ?? 0;
      if (rating > 0) {
        totalRating += rating;
        validRatings++;
      }
    }

    return validRatings > 0 ? totalRating / validRatings : 0.0;
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Reviews Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Customer reviews will appear here once they start reviewing your services.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchReviews,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Check for Reviews',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final avgRating = _calculateAverageRating();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${_reviews.length}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Total Reviews',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                    ],
                  ),
                  const Text(
                    'Average Rating',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building MerchantReviewsPage');
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Customer Reviews',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReviews,
            tooltip: 'Refresh Reviews',
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF6A1B9A),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading your reviews...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
                : _errorMessage != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off,
                            color: Colors.red.shade400,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _fetchReviews,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : _reviews.isEmpty
                ? _buildEmptyState()
                : Column(
                  children: [
                    _buildSummaryHeader(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchReviews,
                        color: const Color(0xFF6A1B9A),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            final rating =
                                int.tryParse(
                                  review['rating']?.toString() ?? '0',
                                ) ??
                                0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: const Color(
                                                    0xFF6A1B9A,
                                                  ),
                                                  radius: 20,
                                                  child: Text(
                                                    (review['reviewerName'] ??
                                                            'A')[0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        review['reviewerName'] ??
                                                            'Anonymous Customer',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      Text(
                                                        _formatDate(
                                                          review['createdAt'],
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildStarRating(rating),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (review['message'] != null &&
                                          review['message'].isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          width: double.infinity,
                                          child: Text(
                                            review['message'],
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      if (review['improvements'] != null &&
                                          review['improvements']
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.shade200,
                                            ),
                                          ),
                                          width: double.infinity,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.lightbulb_outline,
                                                color: Colors.orange.shade600,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Suggested Improvements:',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors
                                                                .orange
                                                                .shade700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      review['improvements'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors
                                                                .orange
                                                                .shade800,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
