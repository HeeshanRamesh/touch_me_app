import 'package:flutter/material.dart';

class CompletedAppointmentScreen extends StatelessWidget {
  const CompletedAppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CompletedAppointmentsTab(),
    );
  }
}

class CompletedAppointmentsTab extends StatefulWidget {
  const CompletedAppointmentsTab({Key? key}) : super(key: key);

  @override
  _CompletedAppointmentsTabState createState() => _CompletedAppointmentsTabState();
}

class _CompletedAppointmentsTabState extends State<CompletedAppointmentsTab> {
  // List of completed appointments
  final List<Map<String, dynamic>> _completedAppointments = [
    {
      'title': 'Haircut',
      'date': '16/01/2025',
      'price': '15,000 LKR',
      'saloon': 'Kamal Dunusinghe',
      'imagePath': 'assets/appointments/haircut_image.png',
    },
    {
      'title': 'Bridal Dressing',
      'date': '16/01/2025',
      'price': '95,000 LKR',
      'saloon': 'Ayeshma K Flo',
      'imagePath': 'assets/appointments/bridal_dressing_image.png',
    },
    {
      'title': 'Makeup',
      'date': '16/01/2025',
      'price': '5,000 LKR',
      'saloon': 'Nathasha Perera',
      'imagePath': 'assets/appointments/makeup_image.png',
    },
    {
      'title': 'Facial',
      'date': '16/01/2025',
      'price': '15,000 LKR',
      'saloon': 'Nethmi Kavya',
      'imagePath': 'assets/appointments/facial_image.png',
    },
    {
      'title': 'Eyebrows Making',
      'date': '16/01/2025',
      'price': '25,000 LKR',
      'saloon': 'Tharushi Sangeewani',
      'imagePath': 'assets/appointments/eyebrows_image.png',
    },
    {
      'title': 'Haircut',
      'date': '16/01/2025',
      'price': '15,000 LKR',
      'saloon': 'Neel Dunusinghe',
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
                              // Handle review action (placeholder for now)
                              print('Review button tapped for ${appointment['title']}');
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