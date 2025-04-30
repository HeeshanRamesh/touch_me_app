import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onSearchPressed;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          InkWell(
            onTap: () => onTap(0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home,
                  size: 20,
                  color: currentIndex == 0 ? const Color(0xFF6A1B9A) : Colors.grey,
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: currentIndex == 0 ? const Color(0xFF6A1B9A) : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Appointments
          InkWell(
            onTap: () => onTap(1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: currentIndex == 1 ? const Color(0xFF6A1B9A) : Colors.grey,
                ),
                Text(
                  'Appointments', // Fixed typo
                  style: TextStyle(
                    color: currentIndex == 1 ? const Color(0xFF6A1B9A) : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Space for the FAB
          // Favourites
          InkWell(
            onTap: () => onTap(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  size: 20,
                  color: currentIndex == 2 ? const Color(0xFF6A1B9A) : Colors.grey,
                ),
                Text(
                  'Favourites',
                  style: TextStyle(
                    color: currentIndex == 2 ? const Color(0xFF6A1B9A) : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Profile
          InkWell(
            onTap: () => onTap(3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: currentIndex == 3 ? const Color(0xFF6A1B9A) : Colors.grey,
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: currentIndex == 3 ? const Color(0xFF6A1B9A) : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FloatingActionButton getFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF6A1B9A),
      child: const Icon(
        Icons.search,
        color: Colors.white,
      ),
      onPressed: onSearchPressed,
    );
  }
}