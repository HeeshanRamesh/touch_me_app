import 'package:flutter/material.dart';
import 'package:touch_me/pages/add_services_screen.dart';

class OwnerServicePage extends StatefulWidget {
  const OwnerServicePage({super.key});

  @override
  State<OwnerServicePage> createState() => _OwnerServicePageState();
}

class _OwnerServicePageState extends State<OwnerServicePage> {
  int _currentIndex = 2; // Set initial index to 2 to highlight "Services"

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6A1B9A),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update index to highlight selected item
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Good Morning",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Arshan Sayed",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0D7F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Kesbewa",
                      style: TextStyle(color: Color(0xFF6A1B9A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFFB71C9B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Search the Service",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Add Service Button
              SizedBox(
                width: double.infinity, // Full-width button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), // Matches your theme
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddServiceScreen()),
                    );
                  },
                  child: const Text(
                    "Add New Service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Service List with responsive design
              _buildServiceItem(
                context: context,
                screenWidth: screenWidth,
                title: "Haircut",
                price: "\$40.00",
                description: "A haircut trims and styles hair, enhancing appearance, personality, and maintaining grooming.",
                discount: "SAVE UP TO 10%",
                dimensions: "347 x 153",
              ),
              _buildServiceItem(
                context: context,
                screenWidth: screenWidth,
                title: "Piercing",
                price: "\$60.00",
                description: "A hair trims and styles hair, enhancing appearance, personality, and maintaining grooming.",
                discount: "SAVE UP TO 20%",
                dimensions: "347 x 153",
              ),
              _buildServiceItem(
                context: context,
                screenWidth: screenWidth,
                title: "Skin Care",
                price: "\$85.00",
                description: "A haircut trims and styles hair, enhancing appearance, personality, and maintaining grooming.",
                discount: "SAVE UP TO 15%",
                dimensions: "347 x 153",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required double screenWidth,
    required String title,
    required String price,
    required String description,
    required String discount,
    required String dimensions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder (using a local asset or a fallback)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/placeholder.png', // Replace with your local asset image path
              width: screenWidth * 0.15, // 15% of screen width for responsiveness
              height: screenWidth * 0.15,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Flexible text content to prevent overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  discount,
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Buttons column to ensure they fit
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: Size(screenWidth * 0.15, 36), // Responsive button size
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () {},
                child: const Text(
                  "Edit",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: Size(screenWidth * 0.15, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () {},
                child: const Text(
                  "Delete",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}