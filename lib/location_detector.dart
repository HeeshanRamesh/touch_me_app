import 'package:flutter/material.dart';
import 'customer_home_screen.dart'; // Import InsideCategoryScreen

class LocationDetectorPage extends StatelessWidget {
  const LocationDetectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Map image at the top
          Container(
            height: MediaQuery.of(context).size.height * 0.5, // Take up 50% of the screen height
            width: double.infinity,
            child: Image.asset(
              'assets/location_map.png', // Replace with your image path
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If the image fails to load, show a placeholder
                debugPrint('Error loading location_map.png: $error');
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
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              'Enable Location Services',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 127, 9, 143), // Purple color
              ),
            ),
          ),
          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Enable your location to receive personalized recommendations for the best local businesses around you. Discover hidden gems, top-rated spots, and unique experiences tailored just for you!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Turn on Location button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to InsideCategoryScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A), // Purple color
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Turn on Location',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Not Now button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: () {
                // Navigate to InsideCategoryScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                side: const BorderSide(color: Color(0xFF6A1B9A)),
              ),
              child: const Text(
                'Not Now',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF6A1B9A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}