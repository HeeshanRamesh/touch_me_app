import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onSearchPressed;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: SizedBox(
        height: 70, // Increased height to accommodate labels
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home Icon with Label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: currentIndex == 0 ? const Color(0xFF6A1B9A) : Colors.grey,
                  ),
                  onPressed: () => onTap(0),
                ),
                Text(
                  'Home',
                  style: TextStyle(
                    color: currentIndex == 0 ? const Color(0xFF6A1B9A) : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            // Grid Icon with Label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: currentIndex == 1 ? const Color(0xFF6A1B9A) : Colors.black,
                  ),
                  onPressed: () => onTap(1),
                ),
                Text(
                  'Appoinmets',
                  style: TextStyle(
                    color: currentIndex == 1 ? const Color(0xFF6A1B9A) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20), // Space for the FAB (Search)
            // Favorites Icon with Notification Badge and Label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        currentIndex == 2 ? Icons.favorite : Icons.favorite_border,
                        color: currentIndex == 2 ? const Color(0xFF6A1B9A) : Colors.grey,
                      ),
                      onPressed: () => onTap(2),
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
                Text(
                  'Favorites',
                  style: TextStyle(
                    color: currentIndex == 2 ? const Color(0xFF6A1B9A) : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            // Profile Icon with Label
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.person_outline,
                    color: currentIndex == 3 ? const Color(0xFF6A1B9A) : Colors.grey,
                  ),
                  onPressed: () => onTap(3),
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: currentIndex == 3 ? const Color(0xFF6A1B9A) : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
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