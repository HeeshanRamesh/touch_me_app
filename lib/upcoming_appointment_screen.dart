import 'package:flutter/material.dart';
import 'package:touch_me/book_appointment_screen.dart';
import 'package:touch_me/inside_appointment_screen.dart';
import 'search_screen.dart'; // Import the SearchScreen
import 'search_date_screen.dart'; // Import the SearchDateScreen
import 'completed_appointment_screen.dart'; // Import the CompletedAppointmentScreen

class UpcomingAppointmentScreen extends StatelessWidget {
  const UpcomingAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UpcomingAppointmentContent(),
    );
  }
}

class UpcomingAppointmentContent extends StatefulWidget {
  const UpcomingAppointmentContent({super.key});

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
        // Placeholder for now; can navigate to a CancelledAppointmentScreen later if needed
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
              // Completed Appointments
              CompletedAppointmentTab(),
              // Cancelled Appointments
              CancelledAppointmentTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class UpcomingAppointmentsTab extends StatelessWidget {
  const UpcomingAppointmentsTab({super.key});

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
                Wrap(
                  spacing: 8.0 * scaleFactor, // Space between buttons
                  runSpacing: 8.0 * scaleFactor, // Space between lines if wrapped
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InsideAppointmentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                        ),
                        minimumSize: Size(0, buttonHeight),
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
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                        ),
                        minimumSize: Size(0, buttonHeight),
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
                        backgroundColor: Colors.purple[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                        ),
                        minimumSize: Size(0, buttonHeight),
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: const Color(0xFF6A1B9A),
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

class CompletedAppointmentTab extends StatefulWidget {
  const CompletedAppointmentTab({super.key});

  @override
  _CompletedAppointmentTabState createState() => _CompletedAppointmentTabState();
}

class _CompletedAppointmentTabState extends State<CompletedAppointmentTab> {
  @override
  void initState() {
    super.initState();
  }

  // Updated list of completed appointments
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
                      Wrap(
                        spacing: 8.0 * scaleFactor, // Space between buttons
                        runSpacing: 8.0 * scaleFactor, // Space between lines if wrapped
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle review action (placeholder for now)
                              print('Review button tapped for ${appointment['title']}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                              ),
                              minimumSize: Size(0, buttonHeight),
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
                              backgroundColor: Colors.purple[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                              ),
                              minimumSize: Size(0, buttonHeight),
                            ),
                            child: Text(
                              'REMOVE',
                              style: TextStyle(
                                color: const Color(0xFF6A1B9A),
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

class CancelledAppointmentTab extends StatefulWidget {
  const CancelledAppointmentTab({super.key});

  @override
  _CancelledAppointmentTabState createState() => _CancelledAppointmentTabState();
}

class _CancelledAppointmentTabState extends State<CancelledAppointmentTab> {
  final TextEditingController _rescheduleNoteController = TextEditingController();
  bool _isRescheduling = false;

  // Define iconSize for consistent scaling
  final double iconSize = 16.0;

  // Sample cancelled appointment data based on the image
  final Map<String, dynamic> _cancelledAppointment = {
    'title': 'Haircut',
    'date': '14/05/2025',
    'price': '15,000 LKR',
    'saloon': 'Komal Dunusinghe',
    'imagePath': 'assets/appointments/haircut_image.png',
  };

  void _toggleReschedule() {
    setState(() {
      _isRescheduling = !_isRescheduling;
    });
  }

  void _removeAppointment() {
    setState(() {
      // Logic to remove the appointment (e.g., clear the data or navigate back)
      Navigator.pop(context); // Placeholder action
    });
  }

  void _requestReschedule() {
    // Placeholder for reschedule logic
    print('Reschedule requested with note: ${_rescheduleNoteController.text}');
    setState(() {
      _isRescheduling = false; // Hide reschedule form after request
    });
  }

  @override
  void dispose() {
    _rescheduleNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const referenceWidth = 375.0;
    final scaleFactor = screenWidth / referenceWidth;

    final cardMarginVertical = 8.0 * scaleFactor;
    final cardMarginHorizontal = 16.0 * scaleFactor;
    final avatarRadius = 30.0 * scaleFactor;
    final titleFontSize = 16.0 * scaleFactor;
    final priceFontSize = 14.0 * scaleFactor;
    final subtitleFontSize = 12.0 * scaleFactor;
    final buttonFontSize = 12.0 * scaleFactor; // Adjusted for readability
    final buttonHeight = 40.0 * scaleFactor;
    final spacing = 8.0 * scaleFactor;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: cardMarginVertical, horizontal: cardMarginHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: cardMarginVertical),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: AssetImage(_cancelledAppointment['imagePath']),
                    onBackgroundImageError: (error, stackTrace) {
                      debugPrint('Error loading ${_cancelledAppointment['imagePath']}: $error');
                    },
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _cancelledAppointment['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _cancelledAppointment['price'],
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
                        _cancelledAppointment['date'],
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: spacing / 2),
                      Text(
                        _cancelledAppointment['saloon'],
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay, color: Colors.grey),
                        onPressed: _toggleReschedule,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: _removeAppointment,
                      ),
                    ],
                  ),
                ),
                if (_isRescheduling) ...[
                  Padding(
                    padding: EdgeInsets.all(cardMarginHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Change Request',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: spacing),
                        TextField(
                          controller: _rescheduleNoteController,
                          decoration: InputDecoration(
                            hintText: 'Type here',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: spacing),
                        Text(
                          'Set date and time for new appointment',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                          ),
                        ),
                        SizedBox(height: spacing),
                        ElevatedButton(
                          onPressed: () {
                             Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                        );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                            ),
                            minimumSize: Size(double.infinity, buttonHeight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.white, size: iconSize),
                              SizedBox(width: 8.0 * scaleFactor),
                              Icon(Icons.access_time, color: Colors.white, size: iconSize),
                              SizedBox(width: 8.0 * scaleFactor),
                              Text(
                                'Reschedule Appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: buttonFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacing),
                        ElevatedButton(
                          onPressed: _requestReschedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                            ),
                            minimumSize: Size(double.infinity, buttonHeight),
                          ),
                          child: Text(
                            'Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}