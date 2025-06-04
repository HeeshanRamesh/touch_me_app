import 'package:flutter/material.dart';
import 'select_category.dart';

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Image
              SizedBox(
                height: height * 0.45,
                width: width,
                child: Image.asset(
                  'assets/onboarding2_image.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Heading
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: height * 0.03,
                ),
                child: Text(
                  'WHERE TRANQUILITY MEETS\nLUXURY, ONE TREATMENT\nAT A TIME.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.028,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 127, 9, 143),
                    height: 1.3,
                  ),
                ),
              ),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Text(
                  'Discover ultimate relaxation at Touch Me. Our expert therapists nurture your well-being, leaving you feeling rejuvenated, peaceful, and radiant after every visit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.02,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: height * 0.04),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(false), _dot(true), _dot(false)],
              ),

              SizedBox(height: height * 0.04),

              // Continue Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectCategoryPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    minimumSize: Size(double.infinity, height * 0.065),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: height * 0.022,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool isActive) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black : Colors.black.withOpacity(0.4),
      ),
    );
  }
}
