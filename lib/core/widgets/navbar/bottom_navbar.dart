// import 'package:boilerplate/core/widgets/search/popover_menu.dart';
import 'package:boilerplate/core/widgets/search/search_modal.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', () {}),
          _buildNavItem(Icons.book, 'My List', () {}),
          _buildNavItem(Icons.list_outlined, 'Categories', () {}),
          _buildNavItem(Icons.search, 'Search', () {SearchModal();}),
          _buildNavItem(Icons.local_activity, 'Activity', () {}),
          _buildNavItem(Icons.settings, 'Settings', () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}