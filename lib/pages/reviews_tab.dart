import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/reviews.dart';

class ReviewsTab extends StatefulWidget {
  final String merchantId;
  final String token;
  final void Function()? onReviewSubmitted;
  final Future<List<Review>>? futureReviews;
  
  const ReviewsTab({
    super.key,
    required this.merchantId,
    required this.token,
    this.onReviewSubmitted,
    this.futureReviews,
  });

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  late Future<List<Review>> _futureReviews;

  @override
  void initState() {
    super.initState();
    print('DEBUG: ReviewsTab initState - merchantId: ${widget.merchantId}');
    _futureReviews = widget.futureReviews ?? fetchReviewsByMerchant(widget.merchantId, widget.token);
  }

  void refreshReviews() {
    print('DEBUG: Refreshing reviews for merchant: ${widget.merchantId}');
    setState(() {
      _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    });
  }

  void _showAddReviewDialog() {
    print('DEBUG: Opening add review dialog');
    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    final improvementsController = TextEditingController();
    int rating = 5;
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rating stars - Fixed layout
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              const Text(
                                'Rating',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  return GestureDetector(
                                    onTap: () => setDialogState(() {
                                      print('DEBUG: Rating selected: ${i + 1}');
                                      rating = i + 1;
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        i < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            labelText: 'Your review *',
                            border: OutlineInputBorder(),
                            hintText: 'Share your experience...',
                          ),
                          minLines: 3,
                          maxLines: 5,
                          maxLength: 500,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your review';
                            }
                            if (val.trim().length < 5) {
                              return 'Review must be at least 5 characters long';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            print('DEBUG: Review message changed: ${val.length} characters');
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: improvementsController,
                          decoration: const InputDecoration(
                            labelText: 'Any suggestions?',
                            border: OutlineInputBorder(),
                            hintText: 'How can we improve?',
                          ),
                          minLines: 2,
                          maxLines: 3,
                          maxLength: 250,
                          onChanged: (val) {
                            print('DEBUG: Improvements changed: ${val.length} characters');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: loading ? null : () {
                    print('DEBUG: Cancel button pressed');
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          print('DEBUG: Submit button pressed');
                          
                          if (!formKey.currentState!.validate()) {
                            print('DEBUG: Form validation failed');
                            return;
                          }

                          final message = messageController.text.trim();
                          final improvements = improvementsController.text.trim();

                          if (message.isEmpty) {
                            print('DEBUG: Empty message after trim');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a review message'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          print('DEBUG: Submitting review - Rating: $rating, Message: ${message.length} chars, Improvements: ${improvements.length} chars');
                          print('DEBUG: Token present: ${widget.token.isNotEmpty}');
                          
                          setDialogState(() => loading = true);

                          try {
                            final success = await addReview(
                              merchantId: widget.merchantId,
                              token: widget.token,
                              message: message,
                              improvements: improvements,
                              rating: rating,
                            );
                            
                            print('DEBUG: Review submission result: $success');
                            
                            if (mounted) {
                              setDialogState(() => loading = false);

                              if (success) {
                                print('DEBUG: Review submitted successfully, closing dialog');
                                Navigator.pop(context);
                                refreshReviews();
                                
                                // Call the callback if provided
                                if (widget.onReviewSubmitted != null) {
                                  widget.onReviewSubmitted!();
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Review submitted successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                print('DEBUG: Review submission failed');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to submit review. Please check your connection and try again.'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            print('DEBUG: Exception during review submission: $e');
                            if (mounted) {
                              setDialogState(() => loading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper: Calculate average rating and rating counts
  Map<String, dynamic> _calcRatingStats(List<Review> reviews) {
    print('DEBUG: Calculating rating stats for ${reviews.length} reviews');
    if (reviews.isEmpty) {
      print('DEBUG: No reviews found, returning default stats');
      return {"avg": 5.0, "counts": List.filled(5, 0)};
    }
    
    final counts = List<int>.filled(5, 0);
    int sum = 0;
    int validReviews = 0;
    
    for (final r in reviews) {
      final rating = r.rating;
      if (rating > 0 && rating <= 5) {
        final idx = rating - 1;
        counts[idx]++;
        sum += rating;
        validReviews++;
      }
    }
    
    final avg = validReviews > 0 ? sum / validReviews : 5.0;
    print('DEBUG: Rating stats - Average: ${avg.toStringAsFixed(2)}, Counts: $counts');
    return {"avg": avg, "counts": counts};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<Review>>(
            future: _futureReviews,
            builder: (context, snapshot) {
              print('DEBUG: FutureBuilder state: ${snapshot.connectionState}');
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                print('DEBUG: Loading reviews...');
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading reviews...'),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                print('DEBUG: Error loading reviews: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Error loading reviews'),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: refreshReviews,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              final reviews = snapshot.data ?? [];
              print('DEBUG: Loaded ${reviews.length} reviews');
              final stats = _calcRatingStats(reviews);
              final avgRating = stats["avg"] as double;
              final ratingCounts = stats["counts"] as List<int>;
              final totalReviews = reviews.length;

              return RefreshIndicator(
                onRefresh: () async {
                  refreshReviews();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Average rating and stats
                      if (reviews.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    avgRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < avgRating.round() ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "$totalReviews Review${totalReviews != 1 ? 's' : ''}",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: List.generate(5, (i) {
                                    final rating = 5 - i;
                                    final count = ratingCounts[4 - i];
                                    final percent = totalReviews > 0 ? count / totalReviews : 0.0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            child: Text(
                                              rating.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: percent,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF6A1B9A),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 20,
                                            child: Text(
                                              count.toString(),
                                              style: const TextStyle(fontSize: 12),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Reviews section title/description
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "See real feedback from customers who visited this merchant.",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Reviews list
                      ...reviews.map((r) => _ReviewCard(review: r)),
                      
                      if (reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "No reviews yet",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Be the first to leave a review!",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Add padding at bottom to avoid FAB overlap
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // FAB "Add Review"
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                print('DEBUG: Add Review FAB pressed');
                _showAddReviewDialog();
              },
              icon: const Icon(Icons.add_comment, color: Colors.white),
              label: const Text(
                'Add Review',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              backgroundColor: const Color(0xFF6A1B9A),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Review Card Widget
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final r = review;
    print('DEBUG: Building review card for review ID: ${r.id}');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reviewer details
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      r.reviewerAvatarUrl ?? "https://randomuser.me/api/portraits/lego/1.jpg",
                    ),
                    radius: 24,
                    onBackgroundImageError: (_, __) {},
                    child: r.reviewerAvatarUrl == null 
                        ? Text(
                            (r.reviewerName?.isNotEmpty == true ? r.reviewerName![0] : r.id.isNotEmpty ? r.id[0] : 'U').toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.reviewerName ?? (r.id.length > 10 ? '${r.id.substring(0, 10)}...' : r.id),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(r.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < r.rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                r.message,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              
              // Improvements/Suggestions
              if (r.improvements.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF6A1B9A),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.improvements,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A1B9A),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Services (if available)
              if (r.services != null && r.services!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: r.services!
                      .map((service) => Chip(
                            label: Text(
                              service,
                              style: const TextStyle(fontSize: 10),
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;
  
  if (difference == 0) {
    return "Today";
  } else if (difference == 1) {
    return "Yesterday";
  } else if (difference < 7) {
    return "$difference days ago";
  } else {
    return "${date.day.toString().padLeft(2, '0')} ${_monthString(date.month)}, ${date.year}";
  }
}

String _monthString(int m) {
  const months = [
    "",
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];
  return months[m];
}