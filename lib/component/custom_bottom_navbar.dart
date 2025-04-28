import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback? onSearchPressed;

  const CustomBottomNavBar({Key? key, this.onSearchPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: SizedBox(
        height: 56, // Standard height for bottom navigation bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Icon with Label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.grey),
                  onPressed: () {},
                ),
                const Text(
                  'Home',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            // Grid View Icon
            IconButton(
              icon: const Icon(Icons.grid_view, color: Colors.grey),
              onPressed: () {},
            ),
            const SizedBox(width: 40), // Space for the FAB
            // Favorites Icon with Notification Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.grey),
                  onPressed: () {},
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            // Profile Icon
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget getFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF6A1B9A), // Purple background
      child: const Icon(
        Icons.search,
        color: Colors.white, // White search icon
      ),
      onPressed: onSearchPressed,
    );
  }
}