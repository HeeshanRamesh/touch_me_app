import 'package:flutter/material.dart';

class ProfilePersonalDetailsScreen extends StatelessWidget {
  const ProfilePersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/profile_picture.png'),
                  child: const Icon(Icons.person, size: 50, color: Colors.grey), // Fallback icon
                ),
              ),
              const SizedBox(height: 30),
              // Name
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE), // Light pink background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Dinuka Sandeep',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // Email
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Dinuka.Sandeep425@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // Phone
              const Text(
                'Phone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  '308 65 123564789',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // Location
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Kesbewa, Colombo',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Male',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 40),
              // Edit Profile Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Edit Profile screen (placeholder)
                    print('Navigate to Edit Profile');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), // Purple background
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}