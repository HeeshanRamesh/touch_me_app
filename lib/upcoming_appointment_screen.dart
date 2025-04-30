import 'package:flutter/material.dart';
import 'search_screen.dart'; // Import the SearchScreen
import 'search_date_screen.dart'; // Import the SearchDateScreen
import 'completed_appointment_screen.dart'; // Import the CompletedAppointmentScreen

class UpcomingAppointmentScreen extends StatelessWidget {
  const UpcomingAppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UpcomingAppointmentContent(),
    );
  }
}

class UpcomingAppointmentContent extends StatefulWidget {
  const UpcomingAppointmentContent({Key? key}) : super(key: key);

  @override
  _UpcomingAppointmentContentState createState() => _UpcomingAppointmentContentState();
}

class _UpcomingAppointmentContentState extends State<UpcomingAppointmentContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Avoid multiple calls during animation
      if (_tabController.index == 1) { // "COMPLETED" tab
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompletedAppointmentScreen()),
        ).then((_) {
          // Reset to "UPCOMING" tab after returning
          _tabController.animateTo(0);
        });
      } else if (_tabController.index == 2) { // "CANCELLED" tab
        // Placeholder for now; can navigate to a CancelledAppointmentScreen later
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions and orientation
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Define a reference width for scaling (based on a typical mobile width)
    const referenceWidth = 375.0;
    final scaleFactor = screenWidth / referenceWidth;

    // Define responsive padding and font sizes
    final topPadding = isLandscape ? 20.0 * scaleFactor : 40.0 * scaleFactor;
    final bottomPadding = 16.0 * scaleFactor;
    final horizontalPadding = 16.0 * scaleFactor;
    final titleFontSize = 24.0 * scaleFactor;
    final searchBarFontSize = 14.0 * scaleFactor;
    final iconSize = 16.0 * scaleFactor;

    return Column(
      children: [
        // Custom Top Section
        Container(
          color: const Color(0xFF6A1B9A),
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: Column(
            children: [
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Appointments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0 * scaleFactor),
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: TextField(
                  readOnly: true, // Prevent keyboard from appearing
                  onTap: () {
                    // Navigate to SearchScreen when the search bar is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Business Name...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: searchBarFontSize,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: iconSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0 * scaleFactor),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0 * scaleFactor),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0 * scaleFactor),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0 * scaleFactor),
                  ),
                ),
              ),
              SizedBox(height: 8.0 * scaleFactor),
              // Filter Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('Location filter tapped');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0 * scaleFactor,
                            horizontal: 16.0 * scaleFactor,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0 * scaleFactor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.grey,
                                size: iconSize,
                              ),
                              SizedBox(width: 8.0 * scaleFactor),
                              Text(
                                'Where...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: searchBarFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0 * scaleFactor),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SearchDateScreen()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0 * scaleFactor,
                            horizontal: 16.0 * scaleFactor,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30.0 * scaleFactor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                                size: iconSize,
                              ),
                              SizedBox(width: 8.0 * scaleFactor),
                              Text(
                                'When...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: searchBarFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0 * scaleFactor),
              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle: TextStyle(fontSize: 14.0 * scaleFactor),
                unselectedLabelStyle: TextStyle(fontSize: 14.0 * scaleFactor),
                tabs: const [
                  Tab(text: 'UPCOMING'),
                  Tab(text: 'COMPLETED'),
                  Tab(text: 'CANCELLED'),
                ],
              ),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Appointments
              UpcomingAppointmentsTab(),
              // Placeholder for Completed tab (navigation handled by TabController listener)
              const Center(child: Text('Completed Appointments')),
              // Cancelled Appointments (Placeholder)
              const Center(child: Text('Cancelled Appointments')),
            ],
          ),
        ),
      ],
    );
  }
}

class UpcomingAppointmentsTab extends StatelessWidget {
  const UpcomingAppointmentsTab({Key? key}) : super(key: key);

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

    final List<Map<String, dynamic>> upcomingAppointments = [
      {
        'title': 'Haircut',
        'date': '18/10/2025',
        'time': '10:00 AM',
        'price': '15,000 LKR',
        'saloon': 'Komal Darasinghe',
        'imagePath': 'assets/appointments/haircut_image.png',
      },
      {
        'title': 'Bridal Dressing',
        'date': '18/10/2025',
        'time': '10:00 AM',
        'price': '95,000 LKR',
        'saloon': 'Komal Darasinghe',
        'imagePath': 'assets/appointments/bridal_dressing_image.png',
      },
      {
        'title': 'Makeup',
        'date': '18/10/2025',
        'time': '10:00 AM',
        'price': '5,000 LKR',
        'saloon': 'Komal Darasinghe',
        'imagePath': 'assets/appointments/makeup_image.png',
      },
      {
        'title': 'Facial',
        'date': '18/10/2025',
        'time': '10:00 AM',
        'price': '15,000 LKR',
        'saloon': 'Nethmi Kavya',
        'imagePath': 'assets/appointments/facial_image.png',
      },
      {
        'title': 'Eyebrows Making',
        'date': '18/10/2025',
        'time': '10:00 AM',
        'price': '25,000 LKR',
        'saloon': 'Tharushi Senanayaka',
        'imagePath': 'assets/appointments/eyebrows_image.png',
      },
      {
        'title': 'Eyebrows Making',
        'date': '18/10/2025',
        'time': '10:00 AM',
        'price': '25,000 LKR',
        'saloon': 'Tharushi Senanayaka',
        'imagePath': 'assets/appointments/eyebrows_image_2.png',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: cardMarginVertical,
        horizontal: isLandscape ? cardMarginHorizontal * 2 : cardMarginHorizontal,
      ),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
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
                  '${appointment['date']}  ${appointment['time']}',
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Equidistant spacing
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle view action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A), // Purple background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                        ),
                        minimumSize: Size(0, buttonHeight), // Scaled button size
                      ),
                      child: Text(
                        'VIEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle change action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A), // Purple background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                        ),
                        minimumSize: Size(0, buttonHeight), // Scaled button size
                      ),
                      child: Text(
                        'CHANGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle cancel action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[100], // Light purple background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                        ),
                        minimumSize: Size(0, buttonHeight), // Scaled button size
                      ),
                      child: Text(
                        'CANCEL',
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