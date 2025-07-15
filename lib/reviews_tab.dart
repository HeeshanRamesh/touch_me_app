import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/reviews.dart';

class ReviewsTab extends StatefulWidget {
  final String merchantId;
  final String token;
  const ReviewsTab({
    super.key,
    required this.merchantId,
    required this.token,
    required void Function() onReviewSubmitted,
    required Future<List<Review>> futureReviews,
  });

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  late Future<List<Review>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
  }

  void refreshReviews() {
    setState(() {
      _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    });
  }

  void _showAddReviewDialog() {
    final formKey = GlobalKey<FormState>();
    String message = '';
    String improvements = '';
    int rating = 5;
    bool loading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 350,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rating stars
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return IconButton(
                              icon: Icon(
                                i < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed:
                                  () => setDialogState(() {
                                    rating = i + 1;
                                  }),
                            );
                          }),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Your review *',
                          ),
                          minLines: 2,
                          maxLines: 4,
                          validator:
                              (val) =>
                                  (val == null || val.isEmpty)
                                      ? 'Message required'
                                      : null,
                          onChanged: (val) => message = val,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Any suggestions? (optional)',
                          ),
                          minLines: 1,
                          maxLines: 2,
                          onChanged: (val) => improvements = val,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      loading
                          ? null
                          : () async {
                            if (!formKey.currentState!.validate()) return;
                            setDialogState(() => loading = true);

                            final success = await addReview(
                              merchantId: widget.merchantId,
                              token: widget.token,
                              message: message,
                              improvements: improvements,
                              rating: rating,
                            );
                            setDialogState(() => loading = false);

                            if (success) {
                              Navigator.pop(context);
                              refreshReviews();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review submitted!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to submit review. Try again!',
                                  ),
                                ),
                              );
                            }
                          },
                  child:
                      loading
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
    if (reviews.isEmpty) return {"avg": 5.0, "counts": List.filled(5, 0)};
    final counts = List<int>.filled(5, 0);
    int sum = 0;
    for (final r in reviews) {
      final idx = (r.rating ?? 5) - 1;
      if (idx >= 0 && idx < 5) counts[idx]++;
      sum += r.rating ?? 5;
    }
    final avg = sum / reviews.length;
    return {"avg": avg, "counts": counts};
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<Review>>(
          future: _futureReviews,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading reviews.'));
            }
            final reviews = snapshot.data ?? [];
            final stats = _calcRatingStats(reviews);
            final avgRating = stats["avg"] as double;
            final ratingCounts = stats["counts"] as List<int>;
            final totalReviews = reviews.length;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Average rating and stats
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 4,
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
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "$totalReviews Reviews",
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
                              final percent =
                                  totalReviews > 0 ? count / totalReviews : 0.0;
                              return Row(
                                children: [
                                  Text(
                                    rating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: percent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFF6A1B9A),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    count.toString(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  ...reviews.map((r) => _ReviewCard(review: r)),
                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text("No reviews yet.")),
                    ),
                ],
              ),
            );
          },
        ),
        // FAB "Add Review"
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddReviewDialog,
            icon: const Icon(Icons.add_comment, color: Colors.white),
            label: const Text(
              'Add Review',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF6A1B9A),
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reviewer details
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/lego/1.jpg",
                    ),
                    radius: 22,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.id, // Or r.reviewerName if available
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatDate(r.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          r.rating,
                          (i) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Message
              Text(r.message, style: const TextStyle(fontSize: 14)),
              if (r.improvements.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    'Suggestions: ${r.improvements}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.purple,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    "${date.day.toString().padLeft(2, '0')} ${_monthString(date.month)}, ${date.year}";

String _monthString(int m) {
  const months = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[m];
}
