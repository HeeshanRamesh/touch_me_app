import 'package:flutter/material.dart';
import 'profile_personal_details_screen.dart';
import 'payment_method_screen.dart'; // Import the new screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 244, 245), // Light grey color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_picture.png'),
              child: Icon(Icons.person, size: 50, color: Colors.grey), // Fallback icon
            ),
            const SizedBox(height: 20),
            // List of Options
            ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: const Text('Personal Details'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePersonalDetailsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.grey),
              title: const Text('Payment Method'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.grey),
              title: const Text('About'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Navigate to About screen (placeholder)
                print('Navigate to About');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Log out'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Handle log out action (placeholder)
                print('Log out');
              },
            ),
          ],
        ),
      ),
    );
  }
}