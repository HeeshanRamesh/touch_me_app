import 'package:flutter/material.dart';
import 'signup_page.dart'; // Import SignUpPage

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({super.key});

  @override
  _SelectCategoryPageState createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  String? _selectedCategory; // Variable to store the selected category

  @override
  Widget build(BuildContext context) {
    // Get screen height for responsive sizing
    final double screenHeight = MediaQuery.of(context).size.height;

    // Debug print to confirm image path
    debugPrint('Attempting to load beauty_tools.png from assets/beauty_tools.png');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: screenHeight * 0.035, // Responsive font size (~24 on a 720p screen)
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 58, 7, 78),
                ),
              ),
              const SizedBox(height: 5),
              // Subtitle
              Text(
                'Welcome to the kingdom of Beauty',
                style: TextStyle(
                  fontSize: screenHeight * 0.022, // Responsive font size (~16 on a 720p screen)
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // Responsive spacing
              // Beauty tools image with placeholder and error handling
              Center(
                child: Container(
                  height: screenHeight * 0.2, // Responsive image height (~150 on a 720p screen)
                  width: screenHeight * 0.2, // Square aspect ratio for debugging
                  child: Image.asset(
                    'assets/beauty_tools.png', // Replace with your image path
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // If the image fails to load, show a placeholder
                      debugPrint('Error loading beauty_tools.png: $error');
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Text(
                            'Image Not Found',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Select Category section
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: screenHeight * 0.025, // Responsive font size (~18 on a 720p screen)
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Radio buttons with borders and background color (smaller boxes)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedCategory == 'Saloon Owners'
                      ? const Color.fromARGB(255, 147, 117, 165)
                      : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  dense: true, // Makes the RadioListTile more compact
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  title: Text(
                    'Saloon Owners',
                    style: TextStyle(fontSize: screenHeight * 0.02), // Smaller font size
                  ),
                  subtitle: Text(
                    'Those who have the shop',
                    style: TextStyle(fontSize: screenHeight * 0.016),
                  ),
                  value: 'Saloon Owners',
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  activeColor: const Color(0xFF6A1B9A),
                  secondary: Image.asset(
                    'assets/saloon_icon.png', // Replace with your saloon icon path
                    height: screenHeight * 0.025, // Smaller icon size (~18 on a 720p screen)
                    width: screenHeight * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedCategory == 'Spa Owners'
                      ? const Color.fromARGB(255, 147, 117, 165)
                      : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  title: Text(
                    'Spa Owners',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                  subtitle: Text(
                    'Those who have self service',
                    style: TextStyle(fontSize: screenHeight * 0.016),
                  ),
                  value: 'Spa Owners',
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  activeColor: const Color(0xFF6A1B9A),
                  secondary: Image.asset(
                    'assets/spa_icon.png', // Replace with your spa icon path
                    height: screenHeight * 0.025,
                    width: screenHeight * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedCategory == 'Customer'
                      ? const Color.fromARGB(255, 147, 117, 165)
                      : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  title: Text(
                    'Customer',
                    style: TextStyle(fontSize: screenHeight * 0.02),
                  ),
                  subtitle: Text(
                    'Those who need Service',
                    style: TextStyle(fontSize: screenHeight * 0.016),
                  ),
                  value: 'Customer',
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  activeColor: const Color(0xFF6A1B9A),
                  secondary: Image.asset(
                    'assets/customer_icon.png', // Replace with your customer icon path
                    height: screenHeight * 0.025,
                    width: screenHeight * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              // Note
              Text(
                'Once you are done selecting your profession, proceed by clicking on the next button',
                style: TextStyle(
                  fontSize: screenHeight * 0.018, // Responsive font size (~14 on a 720p screen)
                  color: Colors.black,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Next button
              ElevatedButton(
                onPressed: _selectedCategory == null
                    ? null // Disable button if no category is selected
                    : () {
                        if (_selectedCategory == 'Customer') {
                          // Navigate to SignUpPage if Customer is selected
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpPage()),
                          );
                        } else {
                          // Show a message for Saloon Owners or Spa Owners
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Registration for $_selectedCategory is not yet available.',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: const Color(0xFF6A1B9A),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A), // Purple color
                  minimumSize: Size(double.infinity, screenHeight * 0.06), // Responsive button height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025, // Responsive font size (~18 on a 720p screen)
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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