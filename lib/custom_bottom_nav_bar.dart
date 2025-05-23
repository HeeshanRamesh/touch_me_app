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
    final screenWidth = MediaQuery.of(context).size.width;
    const referenceWidth = 375.0;
    final scaleFactor = screenWidth / referenceWidth;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.white,
      child: SizedBox(
        height: 70 * scaleFactor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              index: 0,
              isSelected: currentIndex == 0,
              scaleFactor: scaleFactor,
            ),
            _buildNavItem(
              icon: Icons.grid_view,
              label: 'Appointments',
              index: 1,
              isSelected: currentIndex == 1,
              scaleFactor: scaleFactor,
            ),
            SizedBox(width: 20 * scaleFactor),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        currentIndex == 2 ? Icons.favorite : Icons.favorite_border,
                        color: currentIndex == 2
                            ? const Color(0xFF6A1B9A)
                            : Colors.grey,
                        size: 24 * scaleFactor,
                      ),
                      onPressed: () => onTap(2),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        width: 10 * scaleFactor,
                        height: 10 * scaleFactor,
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
                    color: currentIndex == 2
                        ? const Color(0xFF6A1B9A)
                        : Colors.black,
                    fontSize: 12 * scaleFactor,
                  ),
                ),
              ],
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              index: 3,
              isSelected: currentIndex == 3,
              scaleFactor: scaleFactor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required double scaleFactor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey,
            size: 24 * scaleFactor,
          ),
          onPressed: () => onTap(index),
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6A1B9A) : Colors.black,
            fontSize: 12 * scaleFactor,
          ),
        ),
      ],
    );
  }

  Widget getFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF6A1B9A),
      onPressed: onSearchPressed ?? () {},
      child: const Icon(Icons.search, color: Colors.white),
    );
  }
}