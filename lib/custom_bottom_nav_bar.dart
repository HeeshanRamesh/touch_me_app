import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onSearchPressed;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color:
                          currentIndex == 0
                              ? const Color(0xFF6A1B9A)
                              : Colors.grey,
                    ),
                    onPressed: () => onTap(0),
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          currentIndex == 0
                              ? const Color(0xFF6A1B9A)
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Appointments
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.grid_view,
                      color:
                          currentIndex == 1
                              ? const Color(0xFF6A1B9A)
                              : Colors.grey,
                    ),
                    onPressed: () => onTap(1),
                  ),
                  Text(
                    'Appointments',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          currentIndex == 1
                              ? const Color(0xFF6A1B9A)
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Spacer for FAB
            const SizedBox(width: 40),

            // Favorites
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          currentIndex == 2
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              currentIndex == 2
                                  ? const Color(0xFF6A1B9A)
                                  : Colors.grey,
                        ),
                        onPressed: () => onTap(2),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
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
                      fontSize: 12,
                      color:
                          currentIndex == 2
                              ? const Color(0xFF6A1B9A)
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Profile
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      color:
                          currentIndex == 3
                              ? const Color(0xFF6A1B9A)
                              : Colors.grey,
                    ),
                    onPressed: () => onTap(3),
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          currentIndex == 3
                              ? const Color(0xFF6A1B9A)
                              : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating action button for search
  Widget getFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF6A1B9A),
      onPressed: onSearchPressed,
      child: const Icon(Icons.search, color: Colors.white),
    );
  }
}
