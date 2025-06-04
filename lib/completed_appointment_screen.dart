import 'package:flutter/material.dart';
import 'package:touch_me/inside_appointment_review_screen.dart';

class CompletedAppointmentScreen extends StatelessWidget {
  const CompletedAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CompletedAppointmentsTab(),
    );
  }
}

class CompletedAppointmentsTab extends StatefulWidget {
  const CompletedAppointmentsTab({super.key});

  @override
  _CompletedAppointmentsTabState createState() => _CompletedAppointmentsTabState();
}

class _CompletedAppointmentsTabState extends State<CompletedAppointmentsTab> {
  // Updated list of completed appointments to match the edited image
  final List<Map<String, dynamic>> _completedAppointments = [
    {
      'title': 'HAIRCUT',
      'date': '16/01/2025',
      'price': '15,000 LKR',
      'saloon': 'KOMAL DUNUSINGHE',
      'imagePath': 'assets/appointments/haircut_image.png',
    },
    {
      'title': 'BRIDAL DRESING',
      'date': '16/01/2025',
      'price': '95,000 LKR',
      'saloon': 'AYESHMA K. FLO',
      'imagePath': 'assets/appointments/bridal_dressing_image.png',
    },
    {
      'title': 'MAKEUP',
      'date': '16/01/2025',
      'price': '5,000 LKR',
      'saloon': 'NATHASHA PERERA',
      'imagePath': 'assets/appointments/makeup_image.png',
    },
    {
      'title': 'FACIAL',
      'date': '16/01/2025',
      'price': '15,000 LKR',
      'saloon': 'NETHMI KAVYA',
      'imagePath': 'assets/appointments/facial_image.png',
    },
    {
      'title': 'EYEBROWS MAKING',
      'date': '16/01/2025',
      'price': '25,000 LKR',
      'saloon': 'THARUSHI SANJEEWANI',
      'imagePath': 'assets/appointments/eyebrows_image.png',
    },
    {
      'title': 'HAIRCUT',
      'date': '16/01/2025',
      'price': '15,000 LKR',
      'saloon': 'NEEL DUNUSINGHE',
      'imagePath': 'assets/appointments/haircut_image_2.png',
    },
  ];

  void _removeAppointment(int index) {
    setState(() {
      _completedAppointments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and orientation
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Define a reference width for scaling
    const referenceWidth = 375.0;
    final scaleFactor = screenWidth / referenceWidth;

    // Define responsive sizes
    final cardMarginHorizontal = 16.0 * scaleFactor;
    final cardMarginVertical = 8.0 * scaleFactor;
    final avatarRadius = 30.0 * scaleFactor;
    final titleFontSize = 16.0 * scaleFactor;
    final priceFontSize = 14.0 * scaleFactor;
    final subtitleFontSize = 12.0 * scaleFactor;
    final buttonFontSize = 8.0 * scaleFactor;
    final buttonHeight = 30.0 * scaleFactor;
    final spacing = 8.0 * scaleFactor;

    return _completedAppointments.isEmpty
        ? const Center(child: Text('No Completed Appointments'))
        : ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: cardMarginVertical,
              horizontal: isLandscape ? cardMarginHorizontal * 2 : cardMarginHorizontal,
            ),
            itemCount: _completedAppointments.length,
            itemBuilder: (context, index) {
              final appointment = _completedAppointments[index];
              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: cardMarginHorizontal,
                  vertical: cardMarginVertical,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: AssetImage(appointment['imagePath']),
                    onBackgroundImageError: (error, stackTrace) {
                      debugPrint('Error loading ${appointment['imagePath']}: $error');
                    },
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          appointment['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        appointment['price'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: priceFontSize,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['date'],
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        appointment['saloon'],
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                                Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InsideAppointmentReviewScreen()),
                        );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A), // Purple background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                              ),
                              minimumSize: Size(0, buttonHeight), // Scaled button size
                            ),
                            child: Text(
                              'REVIEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonFontSize,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _removeAppointment(index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[100], // Light purple background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                              ),
                              minimumSize: Size(0, buttonHeight), // Scaled button size
                            ),
                            child: Text(
                              'REMOVE',
                              style: TextStyle(
                                color: const Color(0xFF6A1B9A), // Purple text
                                fontSize: buttonFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle tap on appointment if needed
                  },
                ),
              );
            },
          );
  }
}