import 'package:flutter/material.dart';

class HorizontalNavBar extends StatelessWidget {
  final List<String> tabs;
  final String activeTab;
  final Function(String) onTabSelected;

  const HorizontalNavBar({
    Key? key,
    required this.tabs,
    required this.activeTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: tabs.map((tab) {
        final isActive = tab == activeTab;
        return GestureDetector(
          onTap: () => onTabSelected(tab),
          child: Column(
            children: [
              Text(
                tab,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              if (isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 30,
                  color: const Color(0xFF6A1B9A),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}