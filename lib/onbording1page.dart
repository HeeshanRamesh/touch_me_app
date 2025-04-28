import 'package:flutter/material.dart';
import 'onboarding2page.dart'; // Import Onboarding2Page

class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image at the top
          Container(
            height: MediaQuery.of(context).size.height * 0.5, // Take up 50% of the screen height
            width: double.infinity,
            child: Image.asset(
              'assets/onboarding1_image.png', // Image path
              fit: BoxFit.cover,
            ),
          ),
          // Heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              'TIMELESS SOPHISTICATION,\nEACH MOMENT TRANSCENDS\nEXPECTATIONS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 127, 9, 143),
                height: 1.2,
              ),
            ),
          ),
          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Discover your true beauty at Touch Me. Our skilled professionals enhance your natural glow, leaving you feeling confident, empowered, and radiant with every visit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black, // Active dot
                ),
              ),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Continue button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Onboarding2Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Onboarding2Page()),
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
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}