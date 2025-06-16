import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/reviews.dart';

class ReviewsTab extends StatefulWidget {
  final String merchantId;
  final String token;
  const ReviewsTab({super.key, required this.merchantId, required this.token});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  late Future<List<Review>> _futureReviews;
  final _formKey = GlobalKey<FormState>();
  String _message = '';
  String _improvements = '';
  int _rating = 5;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _refreshReviews();
  }

  void _refreshReviews() {
    setState(() {
      _futureReviews = fetchReviewsByMerchant(widget.merchantId, widget.token);
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _submitting = true);

    final success = await addReview(
      merchantId: widget.merchantId,
      token: widget.token,
      message: _message,
      improvements: _improvements,
      rating: _rating,
    );

    setState(() => _submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState?.reset();
      _refreshReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit review.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Review Form
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      'Add Your Review',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Message'),
                      maxLines: 2,
                      minLines: 1,
                      validator:
                          (val) =>
                              val == null || val.length < 10
                                  ? 'Minimum 10 chars'
                                  : null,
                      onSaved: (val) => _message = val ?? '',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Improvements',
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _improvements = val ?? '',
                    ),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Rating'),
                      value: _rating,
                      onChanged: (val) => setState(() => _rating = val ?? 5),
                      items: List.generate(
                        5,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1} Star${i == 0 ? '' : 's'}'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submitReview,
                      child:
                          _submitting
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Submit Review'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Review List
        Expanded(
          child: FutureBuilder<List<Review>>(
            future: _futureReviews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading reviews.'));
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Center(child: Text('No reviews yet.'));
              }
              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, i) {
                  final r = reviews[i];
                  return ListTile(
                    title: Text(r.message),
                    subtitle: Text(
                      'Improvements: ${r.improvements}\nRating: ${r.rating}/5',
                    ),
                    trailing: Text(
                      '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
