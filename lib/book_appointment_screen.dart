import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatelessWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BookAppointmentContent(),
    );
  }
}

class BookAppointmentContent extends StatefulWidget {
  const BookAppointmentContent({Key? key}) : super(key: key);

  @override
  _BookAppointmentContentState createState() => _BookAppointmentContentState();
}

class _BookAppointmentContentState extends State<BookAppointmentContent> {
  final TextEditingController _noteController = TextEditingController();
  DateTime? _selectedDateTime;
  String? _selectedService;

  // Sample list of services for the dropdown
  final List<String> _services = [
    'Haircut',
    'Bridal Dressing',
    'Makeup',
    'Facial',
    'Eyebrows Making',
  ];

  // Sample saloon data
  final Map<String, dynamic> _saloonInfo = {
    'name': 'Komal Dunusinghe',
    'price': '15,000 LKR',
    'imagePath': 'assets/appointments/haircut_image.png',
  };

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _bookAppointment() {
    if (_selectedService == null || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service and date/time')),
      );
      return;
    }
    // Placeholder for booking logic
    print('Booking appointment:');
    print('Service: $_selectedService');
    print('DateTime: $_selectedDateTime');
    print('Note: ${_noteController.text}');
    // Navigate back or show confirmation
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteController.dispose();
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
    final buttonFontSize = 12.0 * scaleFactor;
    final buttonHeight = 40.0 * scaleFactor;
    final spacing = 8.0 * scaleFactor;
    final iconSize = 16.0 * scaleFactor;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: cardMarginVertical,
        horizontal: cardMarginHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: cardMarginVertical),
            child: Text(
              'Book an Appointment',
              style: TextStyle(
                fontSize: titleFontSize * 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Appointment Card
          Card(
            margin: EdgeInsets.symmetric(vertical: cardMarginVertical),
            child: Padding(
              padding: EdgeInsets.all(cardMarginHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saloon Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: AssetImage(_saloonInfo['imagePath']),
                        onBackgroundImageError: (error, stackTrace) {
                          debugPrint('Error loading ${_saloonInfo['imagePath']}: $error');
                        },
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _saloonInfo['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: titleFontSize,
                              ),
                            ),
                            SizedBox(height: spacing / 2),
                            Text(
                              _saloonInfo['price'],
                              style: TextStyle(
                                fontSize: priceFontSize,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing * 2),
                  // Service Selection
                  Text(
                    'Select Service',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing),
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    hint: const Text('Choose a service'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedService = newValue;
                      });
                    },
                    items: _services.map<DropdownMenuItem<String>>((String service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0 * scaleFactor),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  // Date and Time Selection
                  Text(
                    'Set Date and Time',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing),
                  ElevatedButton(
                    onPressed: () => _selectDateTime(context),
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
                          _selectedDateTime == null
                              ? 'Select Date and Time'
                              : '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  // Notes Field
                  Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: spacing),
                  TextField(
                    controller: _noteController,
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
                  SizedBox(height: spacing * 2),
                  // Book Appointment Button
                  ElevatedButton(
                    onPressed: _bookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                      ),
                      minimumSize: Size(double.infinity, buttonHeight),
                    ),
                    child: Text(
                      'Book Appointment',
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
    );
  }
}