import 'package:flutter/material.dart';
import 'book_appointment_screen.dart'; // Import the BookAppointmentScreen

class InsideAppointmentScreen extends StatelessWidget {
  const InsideAppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: InsideAppointmentContent(),
    );
  }
}

class InsideAppointmentContent extends StatefulWidget {
  const InsideAppointmentContent({Key? key}) : super(key: key);

  @override
  _InsideAppointmentContentState createState() => _InsideAppointmentContentState();
}

class _InsideAppointmentContentState extends State<InsideAppointmentContent> {
  void _editAppointment() {
    // Navigate to the BookAppointmentScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
    );
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
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: cardMarginVertical,
          horizontal: cardMarginHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Arrow (simulated header)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: spacing * 2),
            // Appointment Card
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0 * scaleFactor),
              ),
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
                  Padding(
                    padding: EdgeInsets.all(cardMarginHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Promotional Badges
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0 * scaleFactor,
                                vertical: 4.0 * scaleFactor,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B9A),
                                borderRadius: BorderRadius.circular(5.0 * scaleFactor),
                              ),
                              child: Text(
                                'Save Up to 10%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: subtitleFontSize,
                                ),
                              ),
                            ),
                            SizedBox(width: spacing),
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.grey, size: 16.0),
                                SizedBox(width: 4.0 * scaleFactor),
                                Text(
                                  'Touch Me Recommended',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: subtitleFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
                        Text(
                          '5.0 ★ 208 Reviews',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: spacing * 2),
                        // Service Details
                        Text(
                          'Haircut',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '25,000 LKR',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: subtitleFontSize,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8.0 * scaleFactor),
                            Text(
                              '15,000 LKR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: titleFontSize,
                                color: Colors.black,
                              ),
                            ),
                          ],
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
                        // Total and Edit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '15,000 LKR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: titleFontSize,
                                  ),
                                ),
                                Text(
                                  '45 Minutes',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: _editAppointment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                                ),
                                minimumSize: Size(buttonHeight * 2, buttonHeight),
                              ),
                              child: Text(
                                'Edit Appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}