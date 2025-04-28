import 'package:flutter/material.dart';
import 'select_category.dart'; // Import SelectCategoryPage

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

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
              'assets/onboarding2_image.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text(
              'WHERE TRANQUILITY MEETS\nLUXURY, ONE TREATMENT\nAT A TIME.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 127, 9, 143), // Same purple as Onboarding1Page
                height: 1.2,
              ),
            ),
          ),
          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Discover ultimate relaxation at Touch Me. Our expert therapists nurture your well-being, leaving you feeling rejuvenated, peaceful, and radiant after every visit.',
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
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
            ],
          ),
          const SizedBox(height: 30),
          // Continue button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to SelectCategoryPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SelectCategoryPage()),
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