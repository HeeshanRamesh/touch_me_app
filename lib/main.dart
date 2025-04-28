import 'package:flutter/material.dart';
import 'onbording1page.dart'; // Import the Onboarding1Page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Set the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgroundpotrait.png'), // Background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container with white background and rounded corners
              GestureDetector(
                onTap: () {
                  // Navigate to Onboarding1Page when the logo is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Onboarding1Page()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/app_icon.png', // Logo image path
                    height: 250, // Adjust size as needed
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tagline text
              const Text(
                'YOUR NEXT LOOK. ONE CLICK AWAY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              // Footer text with bold style
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'A product of VVH Solutions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold, // Make the text bold
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