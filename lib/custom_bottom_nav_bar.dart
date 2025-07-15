import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = 64.0;
    final floatingDiameter = 68.0;

    return SizedBox(
      height: barHeight + floatingDiameter / 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBarItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    selected: currentIndex == 0,
                  ),
                  _buildBarItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Calendar',
                    index: 1,
                    selected: currentIndex == 1,
                  ),
                  const SizedBox(width: 64), // Space for center button
                  _buildBarItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    index: 2,
                    selected: currentIndex == 2,
                  ),
                  _buildBarItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                    selected: currentIndex == 3,
                  ),
                ],
              ),
            ),
          ),

          // Center Floating Button (Search)
          Positioned(
            bottom: barHeight - floatingDiameter / 2 - 4,
            child: GestureDetector(
              onTap: () => onTabSelected(4), // Index 4 for Search
              child: Container(
                width: floatingDiameter,
                height: floatingDiameter,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D1135), // Deep purple
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEED8FF), // Soft lavender border
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF2D1135) : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? const Color(0xFF2D1135) : Colors.grey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
