import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class InsideAppointmentReviewScreen extends StatelessWidget {
  const InsideAppointmentReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: InsideAppointmentReviewContent(),
    );
  }
}

class InsideAppointmentReviewContent extends StatefulWidget {
  const InsideAppointmentReviewContent({super.key});

  @override
  _InsideAppointmentReviewContentState createState() => _InsideAppointmentReviewContentState();
}

class _InsideAppointmentReviewContentState extends State<InsideAppointmentReviewContent> {
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 0.0;
  bool _showRatingPopup = false;
  bool _showImprovementPopup = false;
  bool _showThankYouPopup = false;

  void _showRatingDialog() {
    setState(() {
      _showRatingPopup = true;
    });
  }

  void _submitRating(double rating) {
    setState(() {
      _rating = rating;
      _showRatingPopup = false;
      _showImprovementPopup = true;
    });
  }

  void _submitImprovement() {
    setState(() {
      _showImprovementPopup = false;
      _showThankYouPopup = true;
    });
  }

  void _rateUs() {
    setState(() {
      _showThankYouPopup = false;
    });
    // Navigate to reviewed state or show reviewed screen
    _showReviewed();
  }

  void _showReviewed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Reviewed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const referenceWidth = 375.0;
    final scaleFactor = screenWidth / referenceWidth;

    final cardMarginVertical = 8.0 * scaleFactor;
    final cardMarginHorizontal = 16.0 * scaleFactor;
    final avatarRadius = 20.0 * scaleFactor;
    final titleFontSize = 16.0 * scaleFactor;
    final subtitleFontSize = 12.0 * scaleFactor;
    final buttonFontSize = 12.0 * scaleFactor;
    final buttonHeight = 40.0 * scaleFactor;
    final spacing = 8.0 * scaleFactor;
    final iconSize = 16.0 * scaleFactor;

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: cardMarginVertical,
              horizontal: cardMarginHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Back Arrow
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Review Appointment',
                        style: TextStyle(
                          fontSize: titleFontSize * 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48.0), // Spacer for symmetry with back arrow
                  ],
                ),
                SizedBox(height: spacing * 2),
                // Appointment Details Card
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(cardMarginHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saloon Image
                        Image.asset(
                          'assets/offers/offer1.png', // Replace with your image asset
                          width: double.infinity,
                          height: 150.0 * scaleFactor,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: spacing),
                        // Saloon Details
                        Text(
                          'Salon Niro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                        ),
                        Text(
                          '12/2/A, Kesbewa, Piliyandala',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: spacing),
                        // Service Details
                        Text(
                          'Haircut',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                        ),
                        Text(
                          '15,000 LKR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '10:30 - 11:15 AM',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '16/01/2025',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: spacing),
                        // Stylist Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundImage: const AssetImage('assets/stylist_image.png'), // Replace with your image asset
                              onBackgroundImageError: (error, stackTrace) {
                                debugPrint('Error loading stylist_image.png: $error');
                              },
                            ),
                            SizedBox(width: spacing),
                            Text(
                              'Kamal Dunusinghe',
                              style: TextStyle(
                                fontSize: titleFontSize,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing * 2),
                        // Trigger Rating Popup
                        ElevatedButton(
                          onPressed: _showRatingDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                            ),
                            minimumSize: Size(double.infinity, buttonHeight),
                          ),
                          child: Text(
                            'Rate Your Experience',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showRatingPopup)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Card(
                margin: EdgeInsets.all(16.0 * scaleFactor),
                child: Padding(
                  padding: EdgeInsets.all(16.0 * scaleFactor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Rate Your Experience with Us!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30.0 * scaleFactor,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: _submitRating,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showImprovementPopup)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Card(
                margin: EdgeInsets.all(16.0 * scaleFactor),
                child: Padding(
                  padding: EdgeInsets.all(16.0 * scaleFactor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Where Can We Improve?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Hair Cut')),
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Shaving')),
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Retouch')),
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Makeup')),
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Massage')),
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Relaxing')),
                          ElevatedButton(onPressed: _submitImprovement, child: const Text('Straining')),
                        ],
                      ),
                     
                    ],
                  ),
                ),
              ),
            ),
          if (_showThankYouPopup)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Card(
                margin: EdgeInsets.all(16.0 * scaleFactor),
                child: Padding(
                  padding: EdgeInsets.all(16.0 * scaleFactor),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Thank You for Loving Us!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Icon(Icons.sentiment_very_satisfied, size: 50, color: Colors.green),
                      ElevatedButton(onPressed: _rateUs, child: const Text('Rate Us!')),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}